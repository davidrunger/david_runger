RSpec.describe Api::ItemsController do
  before { sign_in(user) }

  let(:store) { stores(:store) }
  let(:user) { store.user }
  let(:non_spouse_user) { User.where.not(id: [owning_user, owning_user&.spouse].compact).first! }

  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    context 'when the item params are valid' do
      let(:valid_params) { { store_id: store.id, item: { name: 'Milk', store_id: store.id } } }
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
    end

    context 'when the item params are not valid' do
      let(:invalid_params) { { store_id: store.id, item: { name: '', store_id: store.id } } }
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
      let(:owning_user) { item.store.user }
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
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete(:destroy, params: { id: item.id }) }

    let(:item) { items(:item) }

    context 'when attempting to destroy the item of another (non-spouse) user' do
      let(:owning_user) { item.store.user }
      let(:user) { non_spouse_user }

      it 'does not destroy the item' do
        expect { delete_destroy }.not_to change { item.reload.persisted? }
      end

      it 'returns a 404 status code' do
        delete_destroy
        expect(response).to have_http_status(404)
      end
    end

    context "when attempting to destroy one's own item", :paper_trail do
      let(:user) { item.store.user }

      it 'destroys the item' do
        expect { delete_destroy }.to change { Item.find_by(id: item.id) }.from(Item).to(nil)
      end

      it 'responds with a 200 status code and restore_item_path in JSON' do
        delete_destroy

        expect(response).to have_http_status(200)
        expect(response.parsed_body).to eq(
          'restore_item_path' =>
            api_reifications_path(
              paper_trail_version_id: item.versions.last!,
            ),
        )
      end
    end
  end
end
