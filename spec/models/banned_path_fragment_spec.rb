RSpec.describe BannedPathFragment do
  subject(:banned_path_fragment) { BannedPathFragment.new }

  it { is_expected.to validate_presence_of(:value) }
  it { is_expected.to allow_value('phpmyadmin').for(:value) }
  it { is_expected.to allow_value('%25alevins%25').for(:value) }
  it { is_expected.not_to allow_value('/phpmyadmin').for(:value) }
  it { is_expected.not_to allow_value('old-wp').for(:value) }
end
