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
class QuizQuestionAnswerSelection < ApplicationRecord
  belongs_to :answer, class_name: 'QuizQuestionAnswer'
  belongs_to :participation, class_name: 'QuizParticipation'
  belongs_to :question, class_name: 'QuizQuestion'

  has_one :participant, through: :participation
  has_one :quiz, through: :question

  validates :participation_id, uniqueness: { scope: :question_id }
  validate :answer_must_belong_to_question
  validate :answer_must_belong_to_participation_quiz

  private

  def answer_must_belong_to_question
    if answer.present? && question.present? && answer.question_id != question_id
      errors.add(:answer, 'must belong to the selected question')
    end
  end

  def answer_must_belong_to_participation_quiz
    if participation.present? && question.present? && participation.quiz_id != question.quiz_id
      errors.add(:answer, "must belong to the participation's quiz")
    end
  end
end
