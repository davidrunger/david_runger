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
  # rubocop:disable Rails/HasManyOrHasOneDependent
  # We don't need `:dependent` option because this is a subset of `quiz_question_answer_selections`
  has_many(
    :correct_answer_selections,
    -> do
      joins(answer: :question).
        merge(QuizQuestion.closed).
        where(quiz_question_answers: { is_correct: true })
    end,
    class_name: 'QuizQuestionAnswerSelection',
    foreign_key: :participation_id,
    inverse_of: :participation,
  )
  # rubocop:enable Rails/HasManyOrHasOneDependent

  validates :display_name, presence: true, uniqueness: { scope: :quiz_id }
  validates :participant_id, uniqueness: { scope: :quiz_id }
end
