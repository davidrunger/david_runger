RSpec.describe(ItemSectionAssignment) do
  subject(:item_section_assignment) { build(:item_section_assignment) }

  it { is_expected.to be_valid }

  it 'rejects an availability at another store' do
    item_section_assignment.item_availability = create(:item_availability)

    expect(item_section_assignment).not_to be_valid
    expect(item_section_assignment.errors[:item_availability]).to include(
      'must belong to the configured store',
    )
  end

  it 'rejects a section from another scheme' do
    item_section_assignment.store_section = create(:store_section)

    expect(item_section_assignment).not_to be_valid
    expect(item_section_assignment.errors[:store_section]).to include(
      'must belong to the configured scheme',
    )
  end
end
