RSpec.describe Store do
  describe 'associations' do
    it { is_expected.to have_many(:item_availabilities).dependent(:destroy) }
    it { is_expected.to have_many(:items).through(:item_availabilities) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id) }
  end
end
