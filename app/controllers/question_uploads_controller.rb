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
    @questions = params[:questions]
    result = QuizQuestions::CreateFromList.new!(quiz: @quiz, questions_list: @questions).run

    if result.success?
      redirect_to(@quiz, status: :see_other, notice: 'Questions saved successfully!')
    else
      @error_message = result.error_message
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_quiz
    # rubocop:disable Rails/DynamicFindBy
    @quiz = policy_scope(Quiz).find_by_hashid!(params[:quiz_id])
    # rubocop:enable Rails/DynamicFindBy
  end
end
