RSpec.describe(Items::BulkUpdate::Create) do
  subject(:action) { Items::BulkUpdate::Create.new!(items:, attributes_change:) }

  let(:items) { [item] }
  let(:item) { Item.first!.tap { it.update!(needed: old_needed) } }
  let(:attributes_change) { { 'needed' => new_needed } }
  let(:old_needed) { 55 }
  let(:new_needed) { 0 }

  describe '#run!' do
    subject(:run!) { action.run! }

    it 'changes all of the items as specified by attributes_change' do
      expect { run! }.to change { item.reload.needed }.from(old_needed).to(new_needed)
    end
  end
end
