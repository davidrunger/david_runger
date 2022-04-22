# frozen_string_literal: true

RSpec.describe User do
  subject(:user) { users(:user) }

  it { is_expected.to have_many(:items) }
  it { is_expected.to have_many(:logs) }
  it { is_expected.to have_many(:log_shares) }

  describe '#items' do
    subject(:items) { user.items }

    it 'returns a relation that allows a specific item to be found by `id`' do
      item_id = user.items.first!.id
      expect(user.items.find(item_id)).to eq(Item.find(item_id))
    end
  end
end
