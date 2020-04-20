# frozen_string_literal: true

class LogsController < ApplicationController
  def index
    if params[:user_id] && params[:slug]
      log = Log.find_by!(slug: params[:slug])
      authorize(log, :show?)
      logs = Log.where(id: log)
    elsif current_user.present?
      logs = current_user.logs.order(:created_at)
    else
      fail('Route does not match a shared log and there is no current user')
    end

    @title = 'Logs'
    @body_class = 'sans-serif'
    bootstrap(
      current_user: UserSerializer.new(current_user),
      logs: ActiveModel::Serializer::CollectionSerializer.new(logs),
      log_input_types: log_input_types,
    )
    render :index
  end

  private

  def log_input_types
    [
      {data_type: 'counter', label: 'Counter'},
      {data_type: 'duration', label: 'Duration'},
      {data_type: 'number', label: 'Number'},
      {data_type: 'text', label: 'Text'},
    ]
  end
end
