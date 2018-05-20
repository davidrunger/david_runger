# == Schema Information
#
# Table name: exercise_count_logs
#
#  count       :integer          not null
#  created_at  :datetime         not null
#  exercise_id :bigint(8)        not null
#  id          :bigint(8)        not null, primary key
#  note        :string
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_exercise_count_logs_on_created_at   (created_at)
#  index_exercise_count_logs_on_exercise_id  (exercise_id)
#

class ExerciseCountLog < ApplicationRecord
  belongs_to :exercise, optional: true # not actually optional, but saves an unnecessary DB query

  validates :exercise_id, presence: true
end
