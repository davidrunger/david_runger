class LogsController < ApplicationController
  def index
    @title = 'Logs'
    @body_class = 'sans-serif'
    bootstrap(
      current_user: UserSerializer.new(current_user),
      logs: ActiveModel::Serializer::CollectionSerializer.new(current_user.logs.includes(:log_entries_ordered, :log_inputs)),
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
      {public_type: 'text', label: 'Text'},
    ].select { |input_type| input_type[:public_type].in?(available_input_types) }
  end
end
