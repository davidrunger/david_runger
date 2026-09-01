RSpec.describe Item do
  subject(:item) { items(:item) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:item_availabilities).dependent(:destroy) }
    it { is_expected.to have_many(:stores).through(:item_availabilities) }
  end

  describe 'validations' do
    specify do
      expect(item).to validate_uniqueness_of(:name).
        case_insensitive.
        scoped_to(:user_id)
    end

    specify do
      expect(item).to validate_numericality_of(:needed).
        only_integer.
        is_greater_than_or_equal_to(0)
    end

    context 'when an item name differs only in case and whitespace' do
      let(:duplicate_item) do
        build(
          :item,
          stores: [item.stores.first!],
          name: " \t fish  \t Sticks \t  ",
        )
      end

      before { item.update!(name: 'fish sticks') }

      it 'is not valid' do
        expect(duplicate_item).not_to be_valid
        expect(duplicate_item.errors.of_kind?(:name, :taken)).to eq(true)
      end
    end
  end

  describe '::needed' do
    context 'when `needed` is greater than 0' do
      before { item.update!(needed: 1) }

      it 'includes the item' do
        expect(Item.needed.where(id: item.id)).to exist
      end
    end

    context 'when `needed` is 0' do
      before { item.update!(needed: 0) }

      it 'does not include the item' do
        expect(Item.needed.where(id: item.id)).not_to exist
      end
    end
  end
end
