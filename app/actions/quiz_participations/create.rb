class QuizParticipations::Create < ApplicationAction
  requires :display_name, String
  requires :quiz, Quiz
  requires :user, User

  fails_with :invalid_participation

  def execute
    participation = nil

    quiz.with_lock do
      participation = user.quiz_participations.build(quiz:, display_name:)

      if participation.valid?
        participation.save!
      else
        result.invalid_participation!(participation.errors.full_messages.to_sentence)
      end
    end

    if participation.persisted?
      QuizzesChannel.broadcast_to(quiz, new_participant_name: participation.display_name)
    end
  end
end
