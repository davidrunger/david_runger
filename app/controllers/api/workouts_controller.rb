# frozen_string_literal: true

class Api::WorkoutsController < ApplicationController
  def create
    @workout = current_user.workouts.create!(workout_params)
    render json: @workout, status: :created
  end

  private

  def workout_params
    params.require(:workout).permit(:time_in_seconds, rep_totals: {})
  end
end
