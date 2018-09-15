class LogsController < ApplicationController
  def index
    @title = 'Logs'
    @body_class = 'sans-serif'
    bootstrap(
      current_user: current_user.as_json,
      logs: ActiveModel::Serializer::CollectionSerializer.new(current_user.logs),
      log_input_types: log_input_types,
    )
    render :index
  end

  private

  def log_input_types
    available_input_types = LogInput::PUBLIC_TYPE_TO_TYPE_MAPPING.keys.map(&:to_s)
    [
      {public_type: 'duration', label: 'Duration'},
      {public_type: 'integer', label: 'Integer'},
    ].select { |input_type| input_type[:public_type].in?(available_input_types) }
  end
end
