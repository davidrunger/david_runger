RSpec.describe ItemMerges::Create do
  subject(:merge_items) do
    described_class.run!(source_item:, target_item:).item
  end

  let(:user) { users(:user) }
  let(:shared_store) { create(:store, user:) }
  let(:source_store) { user.stores.first! }
  let(:target_store) { user.stores.where.not(id: source_store).first! }
  let!(:source_item) do
    create(:item, stores: [source_store, shared_store], needed: 3)
  end
  let!(:target_item) do
    create(:item, stores: [target_store, shared_store], needed: 1)
  end

  it 'moves unique availabilities, removes duplicates, and preserves the target item' do
    source_availability = source_item.item_availabilities.find_by!(store: source_store)
    redundant_availability = source_item.item_availabilities.find_by!(store: shared_store)
    target_availability = target_item.item_availabilities.find_by!(store: shared_store)

    expect(merge_items).to eq(target_item)
    expect(Item.find_by(id: source_item)).to be_nil
    expect(target_item.reload.store_ids).
      to contain_exactly(shared_store.id, source_store.id, target_store.id)
    expect(target_item.needed).to eq(3)
    expect(source_availability.reload.item_id).to eq(target_item.id)
    expect(ItemAvailability.find_by(id: redundant_availability)).to be_nil
    expect(target_availability.reload.item_id).to eq(target_item.id)
  end

  context 'when the source and target are the same item' do
    let(:target_item) { source_item }

    it 'rejects the merge' do
      expect { merge_items }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when the source and target belong to different users' do
    let(:target_item) { user.spouse.presence!.items.first! }

    it 'rejects the merge' do
      expect { merge_items }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
