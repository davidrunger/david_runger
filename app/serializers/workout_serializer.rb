# frozen_string_literal: true

# == Schema Information
#
# Table name: workouts
#
#  created_at      :datetime         not null
#  id              :bigint           not null, primary key
#  rep_totals      :jsonb            not null
#  time_in_seconds :integer          not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_workouts_on_user_id  (user_id)
#
class WorkoutSerializer < ActiveModel::Serializer
  attributes :created_at, :id, :rep_totals, :time_in_seconds

  def rep_totals
    # alphabetize keys (workout names)
    workout.rep_totals.sort.to_h
  end

  private

  def workout
    object
  end
end
