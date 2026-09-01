RSpec.describe Api::ItemsController do
  before { sign_in(user) }

  let(:store) { stores(:store) }
  let(:user) { store.user }
  let(:non_spouse_user) { User.where.not(id: [owning_user, owning_user&.spouse].compact).first! }

  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    context 'when the item params are valid' do
      let(:valid_params) { { store_id: store.id, item: { name: 'Milk' } } }
      let(:params) { valid_params }

      it 'returns a 201 status code' do
        post_create
        expect(response).to have_http_status(201)
      end

      it 'creates that item for the store' do
        expect { post_create }.to change { store.reload.items.size }.by(1)
      end

      context 'when the item name contains leading or trailing whitespace' do
        let(:params) { super().deep_merge(item: { name: " cheese \t puffs " }) }

        it 'strips the whitespace' do
          expect { post_create }.
            to change { store.reload.items.order(:created_at).last!.name }.
            to('cheese puffs')
        end
      end

      context 'when an item with the same name and different casing is available at another store' do
        let(:item) { items(:item) }
        let(:store) { item.user.stores.where.not(id: item.stores).first! }
        let(:params) do
          { store_id: store.id, item: { name: "  #{item.name.swapcase}  " } }
        end

        it 'makes the existing item available at the store' do
          item_count_before_post = Item.count

          expect { post_create }.
            to change { store.reload.items.ids }.
            from([]).
            to([item.id])
          expect(Item.count).to eq(item_count_before_post)
          expect(Item.find_by(id: item)).to be_present
        end
      end

      context "when creating an item in a spouse's store" do
        let(:user) { users(:user) }

        context 'when the store is public' do
          let(:store) do
            user.spouse.presence!.stores.find_by!(private: false)
          end

          it 'creates that item for the store' do
            expect { post_create }.to change { store.reload.items.size }.by(1)
          end

          it 'returns a 201 status code' do
            post_create
            expect(response).to have_http_status(201)
          end
        end

        context 'when the store is private' do
          let(:store) do
            user.spouse.presence!.stores.find_by!(private: true)
          end

          it 'does not create an item' do
            expect { post_create }.not_to change { Item.count }
          end

          it 'returns a 404 status code' do
            post_create
            expect(response).to have_http_status(404)
          end
        end
      end
    end

    context 'when an item with the same name is already available at the store' do
      let(:item) { items(:item) }
      let(:store) { item.stores.first! }
      let(:params) do
        { store_id: store.id, item: { name: item.name.swapcase } }
      end

      it 'does not add the item again and reports the duplicate name' do
        expect { post_create }.
          not_to change { [Item.count, ItemAvailability.count] }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq(
          'errors' => ['Name has already been taken'],
        )
      end
    end

    context 'when the item params are not valid' do
      let(:invalid_params) { { store_id: store.id, item: { name: '' } } }
      let(:params) { invalid_params }

      it 'returns a 422 status code' do
        post_create
        expect(response).to have_http_status(422)
      end

      it 'does not create an item' do
        expect { post_create }.not_to change { Item.count }
      end

      it 'responds with error message(s)' do
        post_create
        expect(response.parsed_body).to eq('errors' => ["Name can't be blank"])
      end
    end
  end

  describe '#update' do
    subject(:patch_update) { patch(:update, params:) }

    let(:item) { items(:item) }
    let(:base_params) { { id: item.id } }

    context 'when attempting to update the item of another (non-spouse) user' do
      let(:owning_user) { item.user }
      let(:user) { non_spouse_user }
      let(:params) { base_params.merge(item: { name: "#{item.name} Changed" }) }

      it 'does not update the item' do
        expect { patch_update }.not_to change { item.reload.attributes }
      end

      it 'returns a 404 status code' do
        patch_update
        expect(response).to have_http_status(404)
      end
    end

    context 'when the item is being updated with invalid params' do
      let(:invalid_params) { { item: { name: '' } } }
      let(:params) { base_params.merge(invalid_params) }

      it 'does not update the item' do
        expect { patch_update }.not_to change { item.reload.attributes }
      end

      it 'returns a 422 status code' do
        patch_update
        expect(response).to have_http_status(422)
      end

      it 'responds with error messages' do
        patch_update
        expect(response.parsed_body).to eq('errors' => ["Name can't be blank"])
      end
    end

    context "when renaming an item to another of the owner's item names" do
      let(:merge_target) { create(:item, stores: [merge_target_store]) }
      let(:merge_target_store) do
        item.user.stores.where.not(id: item.stores).first!
      end
      let(:params) do
        base_params.merge(item: { name: "  #{merge_target.name.swapcase}  " })
      end

      it 'describes the conflict and offers the existing item as a merge target' do
        patch_update

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq(
          'errors' => ['Name has already been taken'],
          'name_conflict' => true,
          'merge_target' => {
            'id' => merge_target.id,
            'name' => merge_target.name,
            'needed' => merge_target.needed,
            'store_ids' => merge_target.store_ids,
          },
        )
      end

      context "when the user is the item owner's spouse" do
        let(:user) { item.user.spouse.presence! }

        it 'describes the conflict without offering a merge target' do
          patch_update

          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body).to eq(
            'errors' => ['Name has already been taken'],
            'name_conflict' => true,
          )
        end
      end
    end

    context 'when the item is being updated with a negative `needed` value' do
      let(:params) { base_params.merge(item: { needed: -1 }) }

      it 'does not update the item' do
        expect { patch_update }.not_to change { item.reload.attributes }
      end

      it 'returns a 422 status code' do
        patch_update
        expect(response).to have_http_status(422)
      end
    end

    context 'when the item is being updated with valid params' do
      let(:valid_params) { { item: { name: "#{item.name} Changed" } } }
      let(:params) { base_params.merge(valid_params) }

      it 'updates the item' do
        expect { patch_update }.to change { item.reload.name }
      end

      it 'returns a 200 status code' do
        patch_update
        expect(response).to have_http_status(200)
      end
    end

    context 'when updating the stores where the item is available' do
      let(:other_store) do
        item.user.stores.where.not(id: item.stores).first!
      end
      let(:params) do
        base_params.merge(item: { store_ids: [*item.store_ids, other_store.id] })
      end

      it 'makes the same item available at each store' do
        expect { patch_update }.
          to change { item.reload.store_ids.sort }.
          from(item.store_ids.sort).
          to([*item.store_ids, other_store.id].sort)
      end

      context "when the user is the item owner's spouse" do
        let(:user) { item.user.spouse.presence! }

        it 'does not change the stores' do
          expect { patch_update }.not_to change { item.reload.store_ids }
        end

        it 'returns a 403 status code' do
          patch_update
          expect(response).to have_http_status(403)
        end
      end

      context 'when a requested store belongs to another user' do
        let(:other_store) { users(:single_user).stores.first! }

        it 'does not change the stores' do
          expect { patch_update }.not_to change { item.reload.store_ids }
        end

        it 'returns a 422 status code' do
          patch_update
          expect(response).to have_http_status(422)
        end
      end

      context 'when no stores are requested' do
        let(:params) { base_params.merge(item: { store_ids: [] }) }

        it 'does not remove the item from every store' do
          expect { patch_update }.not_to change { item.reload.store_ids }
        end

        it 'returns a 422 status code' do
          patch_update
          expect(response).to have_http_status(422)
        end
      end
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete(:destroy, params: { id: item.id }) }

    let(:item) { items(:item) }

    context 'when attempting to destroy the item of another (non-spouse) user' do
      let(:owning_user) { item.user }
      let(:user) { non_spouse_user }

      it 'does not destroy the item' do
        expect { delete_destroy }.not_to change { item.reload.persisted? }
      end

      it 'returns a 404 status code' do
        delete_destroy
        expect(response).to have_http_status(404)
      end
    end

    context "when attempting to destroy one's own item", :versioning do
      let(:user) { item.user }
      let!(:item_availabilities) do
        item.stores << item.user.stores.where.not(id: item.stores).first!
        item.item_availabilities.to_a
      end

      it 'destroys the item and all of its availabilities' do
        expect { delete_destroy }.to change { Item.find_by(id: item) }.from(Item).to(nil)
        expect(ItemAvailability.where(item_id: item)).to be_empty
      end

      it 'responds with a 200 status code and restore_item_path in JSON' do
        delete_destroy

        item_availability_version_ids =
          PaperTrail::Version.
            where(
              item_id: item_availabilities,
              item_type: ItemAvailability.name,
            ).
            destroys.
            ids
        expect(response).to have_http_status(200)
        expect(response.parsed_body).to eq(
          'restore_item_path' =>
            api_deleted_item_restorations_path(
              item_availability_version_ids:,
              item_version_id: item.versions.destroys.last!.id,
            ),
        )
      end
    end
  end
end
