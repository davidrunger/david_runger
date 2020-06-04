# frozen_string_literal: true

# == Schema Information
#
# Table name: workouts
#
#  created_at        :datetime         not null
#  id                :bigint           not null, primary key
#  publicly_viewable :boolean          default(FALSE), not null
#  rep_totals        :jsonb            not null
#  time_in_seconds   :integer          not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_workouts_on_created_at  (created_at)
#  index_workouts_on_user_id     (user_id)
#

RSpec.describe WorkoutSerializer do
  subject(:serializer) { WorkoutSerializer.new(workout) }

  let(:workout) { workouts(:workout) }

  specify do
    expect(serializer.to_json).to match_schema('spec/support/schemas/workouts/show.json')
  end
end
