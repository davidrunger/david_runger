require 'spec_helper'

RSpec.describe Exercise, type: :model do
  subject(:exercise) { exercises(:chin_ups) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:user_id) }
end
