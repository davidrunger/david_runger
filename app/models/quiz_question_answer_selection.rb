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

  def select_answer!(new_answer)
    participation.quiz.with_lock do
      current_question = participation.quiz.current_question

      unless answer_is_available?(current_question, new_answer)
        answer_not_available!
      end

      current_question.with_lock do
        answer_not_available! unless current_question.open?

        self.answer = new_answer
        self.question = new_answer.question
        save!
      end
    end
  end

  private

  def answer_is_available?(current_question, new_answer)
    participation.quiz.active? &&
      current_question.present? &&
      new_answer.question_id == current_question.id &&
      (new_record? || question_id == current_question.id)
  end

  def answer_not_available!
    errors.add(:answer, 'is not available for selection')
    raise(ActiveRecord::RecordInvalid, self)
  end

  def answer_must_belong_to_question
    return if answer.blank? || question.blank?

    if answer.question_id != question_id
      errors.add(:answer, 'must belong to the selected question')
    end
  end

  def answer_must_belong_to_participation_quiz
    return if participation.blank? || question.blank?

    if participation.quiz_id != question.quiz_id
      errors.add(:answer, "must belong to the participation's quiz")
    end
  end
end
