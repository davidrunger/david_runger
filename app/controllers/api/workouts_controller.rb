class Api::WorkoutsController < Api::BaseController
  def create
    authorize(Workout)
    @workout = current_user.workouts.create!(workout_params)
    render_schema_json(@workout, status: :created)
  end

  def update
    @workout = current_user.workouts.find(params[:id])
    authorize(@workout)
    @workout.update!(workout_params)
    render_schema_json(@workout)
  end

  private

  def workout_params
    params.require(:workout).permit(:publicly_viewable, :time_in_seconds, rep_totals: {})
  end
end
