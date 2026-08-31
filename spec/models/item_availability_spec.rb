RSpec.describe ItemAvailability do
  subject(:item_availability) { item_availabilities(:item_availability) }

  describe 'associations' do
    it { is_expected.to belong_to(:item) }
    it { is_expected.to belong_to(:store) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:store_id).scoped_to(:item_id) }
  end

  context "when the store belongs to a user other than the item's user" do
    before do
      item_availability.store = users(:single_user).stores.first!
    end

    it 'is invalid' do
      expect(item_availability).not_to be_valid
      expect(item_availability.errors.full_messages_for(:store)).to(
        eq(["Store must belong to the item's user"]),
      )
    end
  end
end
