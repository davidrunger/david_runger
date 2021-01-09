# frozen_string_literal: true

class QuizQuestions::Update < ApplicationAction
  requires :quiz_question, Shaped::Shape(QuizQuestion)
  requires :params, Shaped::Shape(ActionController::Parameters)

  def execute
    quiz_question.update!(params)
    QuizzesChannel.broadcast_to(quiz_question.quiz, command: 'refresh')
  end
end
