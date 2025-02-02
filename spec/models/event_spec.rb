RSpec.describe(Event) do
  describe 'associations' do
    it { is_expected.to belong_to(:admin_user).optional }
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:stack_trace) }
    it { is_expected.to validate_presence_of(:type) }
  end
end
