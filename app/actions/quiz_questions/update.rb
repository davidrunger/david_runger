# frozen_string_literal: true

class QuizQuestions::Update < ApplicationAction
  requires :quiz_question, QuizQuestion
  requires :params, ActionController::Parameters

  def execute
    quiz_question.update!(params)
    QuizzesChannel.broadcast_to(quiz_question.quiz, command: 'refresh')
  end
end
