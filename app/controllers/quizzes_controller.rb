# frozen_string_literal: true

class QuizzesController < ApplicationController
  before_action :enable_turbo

  def show
    @quiz = policy_scope(Quiz).find(params[:id]).decorate
    authorize(@quiz, :show?)
    @title = @quiz.name
    render :show
  end

  def new
    authorize(Quiz, :new?)
    @quiz = current_user.quizzes.build
    render :new
  end

  def create
    authorize(Quiz, :create?)
    quiz = current_user.quizzes.create!(quiz_params)
    redirect_to(quiz_path(quiz))
  end

  private

  def quiz_params
    params.
      require(:quiz).
      permit(:name)
  end
end
