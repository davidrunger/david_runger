RSpec.describe Store do
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id) }
end
