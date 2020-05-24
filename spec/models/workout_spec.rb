# frozen_string_literal: true

RSpec.describe Workout do
  subject(:workout) { workouts(:workout) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:time_in_seconds) }
  it { is_expected.to validate_presence_of(:rep_totals) }
end
