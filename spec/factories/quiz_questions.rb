# frozen_string_literal: true

# == Schema Information
#
# Table name: quiz_questions
#
#  content    :text             not null
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  quiz_id    :bigint           not null
#  status     :string           default("open"), not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_quiz_questions_on_quiz_id  (quiz_id)
#
FactoryBot.define do
  factory :quiz_question do
    association :quiz
    content { "What is the team color of the #{Faker::Team.unique.name.titleize}?" }
  end
end
