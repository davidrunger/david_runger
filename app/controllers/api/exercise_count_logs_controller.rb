class Api::ExerciseCountLogsController < ApplicationController
  def create
    exercise = current_user.exercises.find(exercise_count_log_params[:exercise_id])
    exercise_count_log = exercise.exercise_count_logs.create!(exercise_count_log_params)
    render json: exercise_count_log, status: :created
  end

  private

  def exercise_count_log_params
    params.require(:exercise_count_log).permit(:count, :exercise_id)
  end
end
