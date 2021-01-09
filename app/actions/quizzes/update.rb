# frozen_string_literal: true

class Quizzes::Update < ApplicationAction
  requires :quiz, Shaped::Shape(Quiz)
  requires :params, Shaped::Shape(ActionController::Parameters)

  def execute
    quiz.update!(params)
    QuizzesChannel.broadcast_to(quiz, command: 'refresh')
  end
end
