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
class Workout < ApplicationRecord
  belongs_to :user

  validates :publicly_viewable, inclusion: { in: [false, true] }
  validates :rep_totals, presence: true
  validates :time_in_seconds, presence: true, numericality: { greater_than: 0 }
end
