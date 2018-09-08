class LogsController < ApplicationController
  def index
    @title = 'Log'
    @description = 'Log your weight and exercise history'
    @body_class = 'sans-serif'
    bootstrap(
      current_user: current_user.as_json,
      weight_logs: ActiveModel::Serializer::CollectionSerializer.new(current_user.weight_logs),
    )
    render :index
  end
end
