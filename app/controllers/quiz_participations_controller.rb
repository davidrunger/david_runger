# frozen_string_literal: true

class QuizParticipationsController < ApplicationController
  def create
    authorize(QuizParticipation, :create?)

    quiz = Quiz.find_by_hashid!(params[:quiz_id]) # rubocop:disable Rails/DynamicFindBy
    result = QuizParticipations::Create.new(
      display_name: params[:display_name],
      quiz:,
      user: current_user,
    ).run

    if !result.success?
      # rubocop:disable Rails/ActionControllerFlashBeforeRender
      flash[:alert] = result.error_message
      # rubocop:enable Rails/ActionControllerFlashBeforeRender
    end

    redirect_to(quiz)
  end
end
