# frozen_string_literal: true

# == Schema Information
#
# Table name: quiz_questions
#
#  content    :text             not null
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  quiz_id    :bigint           not null
#  status     :string           default("unstarted"), not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_quiz_questions_on_quiz_id  (quiz_id)
#
class QuizQuestion < ApplicationRecord
  validates :content, presence: true

  belongs_to :quiz

  has_many(
    :answers,
    dependent: :destroy,
    class_name: 'QuizQuestionAnswer',
    foreign_key: :question_id,
    inverse_of: :question,
  )
end
