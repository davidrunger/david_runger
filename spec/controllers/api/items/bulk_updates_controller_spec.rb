RSpec.describe Api::Items::BulkUpdatesController do
  before { sign_in(user) }

  let(:user) { store.user }
  let(:store) { stores(:store) }

  describe '#create' do
    subject(:post_create) do
      post(:create, params: { bulk_update: { item_ids:, attributes_change: { needed: 0 } } })
    end

    context 'when a store has multiple needed items' do
      before do
        (2 - store.items.needed.size).times do
          create(:item, :needed, store:)
        end

        expect(store.items.needed.size).to be >= 2
      end

      context 'when the needed item ids are posted as `item_ids`' do
        let(:item_ids) { store.items.needed.ids }

        it 'changes `needed` for each needed item to zero' do
          expect {
            post_create
          }.to change {
            store.items.needed.size
          }.to(0)
        end
      end

      context 'when item_ids is an empty array' do
        let(:item_ids) { [] }

        it 'responds with no content' do
          post_create

          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
