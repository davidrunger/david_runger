# frozen_string_literal: true

class QuizzesController < ApplicationController
  def show
    # don't use `policy_scope` here, because we want anyone to be able to view any quiz
    @quiz = Quiz.find(params[:id]).decorate
    authorize(@quiz, :show?)
    require_hashid_param!(@quiz)

    @title = @quiz.name
    bootstrap(
      current_user: UserSerializer.new(current_user),
      quiz: QuizSerializer.new(@quiz),
    )
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
    redirect_to(quiz)
  end

  def update
    @quiz = policy_scope(Quiz).find(params[:id])
    authorize(@quiz, :update?)
    Quizzes::Update.new(quiz: @quiz, params: quiz_params).run!
    redirect_to(@quiz)
  end

  private

  def quiz_params
    params.
      require(:quiz).
      permit(:current_question_number, :name, :status)
  end
end
