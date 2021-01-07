# frozen_string_literal: true

class QuizParticipationsController < ApplicationController
  def create
    authorize(QuizParticipation, :create?)
    quiz = Quiz.find(params[:quiz_id])
    current_user.quiz_participations.create!(quiz_id: quiz.id, display_name: params[:display_name])
    redirect_to(quiz)
  end
end
