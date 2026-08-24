RSpec.describe LinkStatusExpectation do
  subject(:link_status_expectation) { build(:link_status_expectation) }

  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_numericality_of(:status).only_integer }
  it { is_expected.to validate_uniqueness_of(:status).scoped_to(:url) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to allow_value('http://example.com').for(:url) }
  it { is_expected.to allow_value('https://example.com').for(:url) }
  it { is_expected.not_to allow_value('example.com').for(:url) }
  it { is_expected.not_to allow_value('prefix https://example.com').for(:url) }

  it 'tracks create events', :versioning do
    expect { link_status_expectation.save! }.
      to change { link_status_expectation.versions.creates.count }.
      from(0).
      to(1)
  end
end
