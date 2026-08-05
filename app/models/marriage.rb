# == Schema Information
#
# Table name: marriages
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#
class Marriage < ApplicationRecord
  has_many :check_ins, dependent: :destroy
  has_many :emotional_needs, dependent: :destroy
  has_many :memberships, dependent: :destroy, class_name: 'MarriageMembership'
  has_many :partners, through: :memberships, source: :user

  has_paper_trail

  class << self
    def with_eager_loading_for_destroy
      includes(
        :memberships,
        check_ins: %i[check_in_submissions need_satisfaction_ratings],
        emotional_needs: :need_satisfaction_ratings,
      )
    end
  end
end
