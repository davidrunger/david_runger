# frozen_string_literal: true

RSpec.describe Item do
  subject(:item) { items(:item) }

  it { is_expected.to belong_to(:store) }

  describe '::needed' do
    context 'when `needed` is greater than 0' do
      before { item.update!(needed: 1) }

      it 'includes the item' do
        expect(Item.needed.where(id: item.id)).to exist
      end
    end

    context 'when `needed` is less than or equal to 0' do
      before { item.update!(needed: 0) }

      it 'does not include the item' do
        expect(Item.needed.where(id: item.id)).not_to exist
      end
    end
  end
end
