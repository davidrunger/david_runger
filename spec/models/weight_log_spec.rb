require 'spec_helper'

RSpec.describe WeightLog, type: :model do
  subject(:weight_log) { weight_logs(:weight_log) }

  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:weight) }

  it { is_expected.to belong_to(:user) }
end
