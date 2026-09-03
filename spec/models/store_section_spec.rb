RSpec.describe(StoreSection) do
  subject(:store_section) { build(:store_section) }

  it { is_expected.to be_valid }

  it 'requires a case-insensitively unique name per scheme' do
    store_section_scheme = create(:store_section_scheme)
    existing_section = create(:store_section, store_section_scheme:)
    store_section.store_section_scheme = store_section_scheme
    store_section.name = existing_section.name.upcase

    expect(store_section).not_to be_valid
  end
end
