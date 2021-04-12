# frozen_string_literal: true

class QuizParticipations::Create < ApplicationAction
  requires :display_name, String
  requires :quiz, Quiz
  requires :user, User

  fails_with :invalid_participation

  def execute
    participation = user.quiz_participations.build(quiz_id: quiz.id, display_name: display_name)

    if participation.valid?
      participation.save!
      QuizzesChannel.broadcast_to(quiz, new_participant_name: participation.display_name)
    else
      result.invalid_participation!(participation.errors.full_messages.to_sentence)
    end
  end
end
