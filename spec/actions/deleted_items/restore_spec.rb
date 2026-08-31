RSpec.describe DeletedItems::Restore, :versioning do
  describe '.run!' do
    subject(:restore_item) do
      described_class.run!(item_availability_versions: [], item_version:)
    end

    let(:item) { items(:item) }
    let(:item_version) { item.versions.destroys.last! }

    before { item.destroy! }

    it 'rejects a restoration without availability versions' do
      expect { restore_item }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
