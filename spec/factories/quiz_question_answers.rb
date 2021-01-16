# frozen_string_literal: true

# == Schema Information
#
# Table name: quiz_question_answers
#
#  content     :text             not null
#  created_at  :datetime         not null
#  id          :bigint           not null, primary key
#  is_correct  :boolean          default(FALSE), not null
#  question_id :bigint           not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_quiz_question_answers_on_question_id  (question_id)
#
FactoryBot.define do
  factory :quiz_question_answer do
    association :question
    content { Faker::Color.unique.color_name.titleize }
  end
end
