RSpec.describe(StoreSectionScheme) do
  subject(:store_section_scheme) { build(:store_section_scheme) }

  it { is_expected.to be_valid }

  it 'requires a name' do
    store_section_scheme.name = ''

    expect(store_section_scheme).not_to be_valid
  end

  it 'requires a case-insensitively unique name per user' do
    user = create(:user)
    existing_scheme = create(:store_section_scheme, user:, name: 'Costco')
    store_section_scheme.user = user
    store_section_scheme.name = existing_scheme.name.upcase

    expect(store_section_scheme).not_to be_valid
  end
end
