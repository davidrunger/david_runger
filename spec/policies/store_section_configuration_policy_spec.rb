RSpec.describe(StoreSectionConfigurationPolicy) do
  subject(:policy) { described_class.new(user, store_section_configuration) }

  let(:user) { users(:user) }
  let(:store_section_configuration) do
    store_section_configurations(:store_section_configuration)
  end

  describe '#scope' do
    subject(:scope) { policy.scope }

    let!(:other_users_configuration) do
      create(:store_section_configuration, user: users(:single_user))
    end

    it "returns the current user's configurations" do
      expect(scope).to contain_exactly(store_section_configuration)
      expect(scope).not_to include(other_users_configuration)
    end
  end
end
