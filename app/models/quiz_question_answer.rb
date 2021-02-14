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
class QuizQuestionAnswer < ApplicationRecord
  validates :content, presence: true

  belongs_to :question, class_name: 'QuizQuestion'

  has_many(
    :selections,
    dependent: :destroy,
    class_name: 'QuizQuestionAnswerSelection',
    foreign_key: 'answer_id',
    inverse_of: :answer,
  )
  has_many(
    :answering_participations,
    through: :selections,
    source: :participation,
  )

  scope :correct, -> { where(is_correct: true) }
end
