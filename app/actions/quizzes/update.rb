# frozen_string_literal: true

class Quizzes::Update < ApplicationAction
  requires :quiz, Quiz
  requires :params, ActionController::Parameters

  def execute
    quiz.update!(params)
    QuizzesChannel.broadcast_to(quiz, command: 'refresh')
  end
end
