class LogsController < ApplicationController
  def index
    @title = 'Log'
    @description = 'Log your weight and exercise history'
    bootstrap(
      current_user: current_user.as_json,
      exercises: ActiveModel::Serializer::CollectionSerializer.new(current_user.exercises),
      weight_logs: ActiveModel::Serializer::CollectionSerializer.new(current_user.weight_logs),
    )
    render :index
  end
end
