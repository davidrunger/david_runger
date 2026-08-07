# == Schema Information
#
# Table name: quiz_question_answer_selections
#
#  answer_id        :bigint           not null
#  created_at       :datetime         not null
#  id               :bigint           not null, primary key
#  participation_id :bigint           not null
#  question_id      :bigint           not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_quiz_question_answer_selections_on_answer_id         (answer_id)
#  index_quiz_question_answer_selections_on_question_id       (question_id)
#  uniq_quiz_answer_selections_on_participation_and_question  (participation_id,question_id) UNIQUE
#
FactoryBot.define do
  factory :quiz_question_answer_selection do
    association :answer
    association :participation, factory: :quiz_participation
    question { answer.question }
  end
end
