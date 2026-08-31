RSpec.describe Stores::Destroy do
  subject(:destroy_store) { described_class.run!(store:) }

  let(:user) { users(:user) }
  let(:store) { user.stores.first! }
  let(:other_store) { user.stores.where.not(id: store).first! }
  let!(:store_only_item) { create(:item, stores: [store]) }
  let!(:shared_item) { create(:item, stores: [store, other_store]) }

  it 'destroys orphaned items while preserving items available elsewhere' do
    shared_item_updated_at = shared_item.updated_at

    destroy_store

    expect(Store.find_by(id: store)).to be_nil
    expect(Item.find_by(id: store_only_item)).to be_nil
    expect(shared_item.reload.stores).to contain_exactly(other_store)
    expect(shared_item.updated_at).to be > shared_item_updated_at
  end

  it 'broadcasts surviving items with their remaining stores', :action_cable_test_adapter do
    expect { destroy_store }.
      to broadcast_to(GroceriesChannel.broadcasting_for(user.marriage)).
      with(
        hash_including(
          action: 'updated',
          model: hash_including(id: shared_item.id, store_ids: [other_store.id]),
        ),
      )
  end
end
