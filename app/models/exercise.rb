# == Schema Information
#
# Table name: exercises
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null
#
# Indexes
#
#  index_exercises_on_user_id  (user_id)
#

class Exercise < ApplicationRecord
  belongs_to :user, optional: true # not actually optional, but this saves an unnecessary DB query
  has_many :exercise_count_logs, dependent: :destroy

  validates :name, presence: true
  validates :user_id, presence: true
end
