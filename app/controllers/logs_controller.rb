# frozen_string_literal: true

class LogsController < ApplicationController
  def index
    @title = 'Logs'
    @body_class = 'sans-serif'
    bootstrap(
      current_user: UserSerializer.new(current_user),
      logs: ActiveModel::Serializer::CollectionSerializer.new(
        current_user.logs.order(:created_at),
      ),
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
