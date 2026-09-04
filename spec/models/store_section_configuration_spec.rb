RSpec.describe(StoreSectionConfiguration) do
  subject(:configuration) { build(:store_section_configuration) }

  it { is_expected.to be_valid }

  describe 'store ownership' do
    it 'allows a spouse store' do
      user = users(:user)
      spouse_store = user.spouse.stores.first!
      configuration = build(
        :store_section_configuration,
        user:,
        store: spouse_store,
        store_section_scheme: create(:store_section_scheme, user:),
      )

      expect(configuration).to be_valid
    end

    it "rejects another user's store" do
      configuration.store = create(:store)

      expect(configuration).not_to be_valid
      expect(configuration.errors[:store]).to include('must belong to the user or their spouse')
    end
  end

  describe 'store section scheme' do
    it 'requires a scheme when sectioning is enabled' do
      configuration.store_section_scheme = nil

      expect(configuration).not_to be_valid
      expect(configuration.errors[:store_section_scheme]).to include("can't be blank")
    end

    it 'allows a disabled configuration to retain its scheme' do
      configuration.sectioning_enabled = false

      expect(configuration).to be_valid
    end

    it 'allows a disabled configuration without a scheme' do
      configuration.sectioning_enabled = false
      configuration.store_section_scheme = nil

      expect(configuration).to be_valid
    end

    it "rejects another user's scheme" do
      configuration.store_section_scheme = create(:store_section_scheme)

      expect(configuration).not_to be_valid
      expect(configuration.errors[:store_section_scheme]).to include('must belong to the user')
    end

    it 'rejects a missing scheme' do
      configuration.store_section_scheme_id = StoreSectionScheme.maximum(:id) + 1

      expect(configuration).not_to be_valid
      expect(configuration.errors[:store_section_scheme]).to include('must belong to the user')
    end
  end
end
