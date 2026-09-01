RSpec.describe Api::ItemMergesController do
  describe '#create' do
    subject(:post_create) do
      post(
        :create,
        params: {
          source_item_id: source_item.id,
          target_item_id: target_item.id,
        },
      )
    end

    let(:source_item) { create(:item, stores: [source_store], needed: 3) }
    let(:target_item) { create(:item, stores: [target_store], needed: 1) }
    let(:source_store) { owner.stores.first! }
    let(:target_store) { owner.stores.where.not(id: source_store).first! }
    let(:owner) { users(:user) }
    let(:user) { owner }

    before do
      source_item
      target_item
      sign_in(user)
    end

    context 'when the user owns both items' do
      it 'merges the source item into the target item' do
        post_create

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.except('store_ids')).to eq(
          'id' => target_item.id,
          'name' => target_item.name,
          'needed' => 3,
        )
        expect(response.parsed_body.fetch('store_ids')).
          to contain_exactly(source_store.id, target_store.id)
        expect(Item.find_by(id: source_item)).to be_nil
      end
    end

    context "when the user is the items' owner's spouse" do
      let(:user) { owner.spouse.presence! }

      it 'does not merge the items' do
        expect { post_create }.not_to change { Item.count }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
