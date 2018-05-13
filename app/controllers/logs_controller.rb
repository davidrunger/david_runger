class LogsController < ApplicationController
  def index
    @title = 'Log'
    @description = 'Log your weight and exercise history'
    bootstrap(current_user: current_user.as_json)
    render :index
  end
end
