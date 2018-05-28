class LogsController < ApplicationController
  def index
    @title = 'Log'
    @description = 'Log your weight and exercise history'
    @body_class = 'sans-serif'
    bootstrap(
      current_user: current_user.as_json,
      exercise_counts_today: ExerciseCountsTodaySerializer.new(current_user),
      exercises: ActiveModel::Serializer::CollectionSerializer.new(current_user.exercises),
      latest_sets: LatestSetsSerializer.new(current_user),
      weight_logs: ActiveModel::Serializer::CollectionSerializer.new(current_user.weight_logs),
    )
    render :index
  end
end
