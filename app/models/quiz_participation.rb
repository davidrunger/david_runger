# == Schema Information
#
# Table name: quiz_participations
#
#  created_at     :datetime         not null
#  display_name   :string           not null
#  id             :bigint           not null, primary key
#  participant_id :bigint           not null
#  quiz_id        :bigint           not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_quiz_participations_on_participant_id              (participant_id)
#  index_quiz_participations_on_quiz_id_and_display_name    (quiz_id,display_name) UNIQUE
#  index_quiz_participations_on_quiz_id_and_participant_id  (quiz_id,participant_id) UNIQUE
#
class QuizParticipation < ApplicationRecord
  belongs_to :quiz
  belongs_to :participant, class_name: 'User'

  has_many(
    :quiz_question_answer_selections,
    dependent: :destroy,
    foreign_key: :participation_id,
    inverse_of: :participation,
  )

  validates :display_name, presence: true, uniqueness: { scope: :quiz_id }
  validates :participant_id, uniqueness: { scope: :quiz_id }
  validate :quiz_must_be_unstarted, on: :create

  def correct_answer_count
    quiz_question_answer_selections.count { |selection| selection.answer.is_correct? }
  end

  private

  def quiz_must_be_unstarted
    if quiz.present? && !quiz.unstarted?
      errors.add(:quiz, 'has already started')
    end
  end
end
