# frozen_string_literal: true

# == Schema Information
#
# Table name: quiz_question_answer_selections
#
#  answer_id        :bigint           not null
#  created_at       :datetime         not null
#  id               :bigint           not null, primary key
#  participation_id :bigint           not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_quiz_question_answer_selections_on_answer_id         (answer_id)
#  index_quiz_question_answer_selections_on_participation_id  (participation_id)
#
FactoryBot.define do
  factory :quiz_question_answer_selection do
    association :answer
    association :participation, factory: :quiz_participation
  end
end
