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
    QuizQuestions::CreateFromList.new(quiz: @quiz, questions_list: params[:questions]).run!
    redirect_to(@quiz)
  end

  private

  def set_quiz
    @quiz = policy_scope(Quiz).find(params[:quiz_id])
  end
end
