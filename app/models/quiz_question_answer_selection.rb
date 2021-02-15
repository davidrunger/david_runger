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
class QuizQuestionAnswerSelection < ApplicationRecord
  belongs_to :answer, class_name: 'QuizQuestionAnswer'
  belongs_to :participation, class_name: 'QuizParticipation'

  has_one :participant, through: :participation
  has_one :question, through: :answer
  has_one :quiz, through: :question

  validate :only_one_selection_per_question

  private

  def only_one_selection_per_question
    if question.answer_selections.where.not(id: id).exists?(participation: participation)
      errors.add(:base, 'Question has already been answered')
    end
  end
end
