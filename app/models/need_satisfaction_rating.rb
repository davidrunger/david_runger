# frozen_string_literal: true

# == Schema Information
#
# Table name: need_satisfaction_ratings
#
#  check_in_id       :bigint           not null
#  created_at        :datetime         not null
#  emotional_need_id :bigint           not null
#  id                :bigint           not null, primary key
#  score             :integer
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_need_satisfaction_ratings_on_check_in_id        (check_in_id)
#  index_need_satisfaction_ratings_on_emotional_need_id  (emotional_need_id)
#  index_need_satisfaction_ratings_on_user_id            (user_id)
#
class NeedSatisfactionRating < ApplicationRecord
  belongs_to :emotional_need
  belongs_to :user
  belongs_to :check_in

  scope :completed, -> { where.not(score: nil) }

  validates :score, numericality: { only_integer: true, in: (-3..3), allow_nil: true }

  has_paper_trail
end
