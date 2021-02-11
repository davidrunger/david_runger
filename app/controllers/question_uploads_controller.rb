# frozen_string_literal: true

class QuestionUploadsController < ApplicationController
  before_action :set_quiz, only: %i[new create]

  self.container_classes = QuizzesController.container_classes

  def new
    authorize(QuizQuestion, :new?)
    authorize(@quiz, :show?)
  end

  def create
    authorize(QuizQuestion, :create?)
    authorize(QuizQuestionAnswer, :create?)
    QuizQuestions::CreateFromList.run!(quiz: @quiz, questions_list: params[:questions])
    redirect_to(@quiz)
  end

  private

  def set_quiz
    # rubocop:disable Rails/DynamicFindBy
    @quiz = policy_scope(Quiz).find_by_hashid!(params[:quiz_id])
    # rubocop:enable Rails/DynamicFindBy
  end
end
