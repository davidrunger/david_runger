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
class Workout < ApplicationRecord
  belongs_to :user

  validates :time_in_seconds, presence: true, numericality: {greater_than: 0}
  validates :rep_totals, presence: true
end
