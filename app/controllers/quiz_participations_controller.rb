# frozen_string_literal: true

class QuizParticipationsController < ApplicationController
  def create
    authorize(QuizParticipation, :create?)

    quiz = Quiz.find(params[:quiz_id])
    QuizParticipations::Create.new(
      display_name: params[:display_name],
      quiz: quiz,
      user: current_user,
    ).run!

    redirect_to(quiz)
  end
end
