# frozen_string_literal: true

class Api::CheckInSubmissionsController < ApplicationController
  def create
    authorize(CheckInSubmission)
    check_in = policy_scope(CheckIn).find(params[:check_in_id])
    submission =
      policy_scope(CheckInSubmission).find_or_initialize_by(check_in:, user: current_user)
    if submission.persisted?
      head :no_content
    elsif !check_in.decorate.all_ratings_scored_by_self?
      render json: { error: 'You must submit all ratings first' }, status: :unprocessable_entity
    else
      CheckInSubmissions::Create.run!(submission:, user: current_user)
    end
  end
end
