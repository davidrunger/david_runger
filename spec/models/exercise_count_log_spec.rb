require 'spec_helper'

RSpec.describe ExerciseCountLog, type: :model do
  subject(:exercise_count_log) { exercise_count_logs(:chin_ups_count_log) }

  it { is_expected.to belong_to(:exercise) }

  it { is_expected.to validate_presence_of(:exercise_id) }
end
