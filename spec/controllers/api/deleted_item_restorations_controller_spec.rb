RSpec.describe Api::DeletedItemRestorationsController, :versioning do
  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    let(:item) { items(:item) }
    let(:other_store) { item.user.stores.where.not(id: item.stores).first! }
    let!(:item_availabilities) do
      item.stores << other_store
      item.item_availabilities.to_a
    end
    let(:item_availability_version_ids) do
      PaperTrail::Version.
        where(
          item_id: item_availabilities,
          item_type: ItemAvailability.name,
        ).
        destroys.
        ids
    end
    let(:item_version_id) { item.versions.destroys.last!.id }
    let(:params) { { item_availability_version_ids:, item_version_id: } }

    before { item.destroy! }

    context 'when logged in as the user who owns the destroyed item' do
      before { sign_in(item.user) }

      it 'restores the item and all of its availability records' do
        post_create

        expect(item.reload.item_availability_ids).
          to match_array(item_availabilities.map(&:id))
        expect(item.store_ids).to match_array(item_availabilities.map(&:store_id))
      end

      it 'returns the restored item' do
        post_create

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq(
          'id' => item.id,
          'name' => item.name,
          'needed' => item.needed,
          'store_ids' => item_availabilities.map(&:store_id),
        )
      end

      context 'when an availability version does not belong to the item' do
        let(:unrelated_item) { item.user.items.where.not(id: item).first! }
        let!(:unrelated_item_availability) do
          unrelated_item.item_availabilities.first!
        end
        let(:item_availability_version_ids) do
          PaperTrail::Version.
            where(
              item_id: [
                item_availabilities.first,
                unrelated_item_availability,
              ],
              item_type: ItemAvailability.name,
            ).
            destroys.
            ids
        end

        before { unrelated_item.destroy! }

        it 'does not restore the item' do
          expect { post_create }.to raise_error(ActiveRecord::RecordNotFound)

          expect(Item.find_by(id: item)).to be_nil
        end
      end

      context 'when an availability version does not exist' do
        let(:item_availability_version_ids) { [0] }

        it 'does not restore the item' do
          expect { post_create }.to raise_error(ActiveRecord::RecordNotFound)

          expect(Item.find_by(id: item)).to be_nil
        end
      end
    end

    context 'when logged in as a user who does not own the destroyed item' do
      before { sign_in(User.excluding(item.user).first!) }

      it 'does not restore the item' do
        post_create

        expect(Item.find_by(id: item)).to be_nil
      end
    end
  end
end
