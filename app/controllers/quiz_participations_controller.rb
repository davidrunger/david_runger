class QuizParticipationsController < ApplicationController
  def create
    authorize(QuizParticipation, :create?)

    quiz = Quiz.find_by_hashid!(params[:quiz_id])
    result = QuizParticipations::Create.new(
      display_name: params[:display_name],
      quiz:,
      user: current_user,
    ).run

    if !result.success?
      flash[:alert] = result.error_message
    end

    redirect_to(quiz)
  end
end
