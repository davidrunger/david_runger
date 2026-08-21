class QuizzesController < ApplicationController
  self.container_classes = %w[py-2 px-8]

  def index
    authorize(Quiz, :index?)
    @title = 'Quizzes'
    @quizzes = policy_scope(Quiz).order(created_at: :desc)
  end

  def show
    @quiz =
      policy_scope(Quiz).
        includes(participations: { quiz_question_answer_selections: :answer }).
        includes(ordered_questions: { answers: { selections: :participation } }).
        find_by_hashid!(params[:id])
    authorize(@quiz, :show?)
    @title = @quiz.name
  end
end
