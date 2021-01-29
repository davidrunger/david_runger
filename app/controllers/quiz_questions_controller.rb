# frozen_string_literal: true

class QuizQuestionsController < ApplicationController
  before_action :set_quiz_question, only: %i[update]

  def update
    authorize(@quiz_question, :update?)
    QuizQuestions::Update.run!(quiz_question: @quiz_question, params: quiz_question_params)
    redirect_to(@quiz_question.quiz)
  end

  private

  def set_quiz_question
    @quiz_question = policy_scope(QuizQuestion).find(params[:id])
  end

  def quiz_question_params
    params.require(:quiz_question).permit(:status)
  end
end
