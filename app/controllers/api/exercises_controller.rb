class Api::ExercisesController < ApplicationController
  def create
    exercise = current_user.exercises.create!(exercise_params)
    render json: exercise, status: :created
  end

  private

  def exercise_params
    params.require(:exercise).permit(:name)
  end
end
