# frozen_string_literal: true

RSpec.describe Api::Items::BulkUpdateController do
  before { sign_in(user) }

  let(:user) { store.user }
  let(:store) { stores(:store) }

  describe '#create' do
    subject(:post_create) do
      post(
        :create,
        params: {
          bulk_update: {
            item_ids: item_ids,
            attributes_change: { needed: 0 },
          },
        },
      )
    end

    context 'when a store has multiple needed items' do
      before do
        2.times do
          if store.items.needed.size < 2
            create(:item, :needed, store: store)
          end
        end

        expect(store.items.needed.size).to be >= 2
      end

      context 'when the needed item ids are posted as `item_ids`' do
        let(:item_ids) { store.items.needed.ids }

        context 'when the `attributes_change` is `{ needed: 0 }`' do
          let(:attributes_change) { { needed: 0 } }

          it 'changes `needed` for each needed item to zero' do
            expect {
              post_create
            }.to change {
              store.items.needed.size
            }.to(0)
          end
        end
      end
    end
  end
end
