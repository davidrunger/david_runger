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

FactoryBot.define do
  factory :exercise_count_log do
    exercise { Exercise.first! }
    count { 5 }
    note { 'This set was really hard, but I did it!' }
  end
end
