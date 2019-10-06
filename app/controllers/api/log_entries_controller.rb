# frozen_string_literal: true

class Api::LogEntriesController < ApplicationController
  def create
    log = current_user.logs.find(params.dig(:log_entry, :log_id))
    log_entry_params = params.require(:log_entry).permit(:data, :log_id, :note)
    @log_entry = log.log_entries.build(log_entry_params)
    if @log_entry.save
      render json: @log_entry, status: :created
    else
      render json: {errors: @log_entry.errors.to_h}, status: :unprocessable_entity
    end
  end

  # currently only works for `TextLogEntry`s
  def update
    @log_entry = current_user.text_log_entries.find(params['id'])
    log_entry_params = params.require(:log_entry).permit(:data)
    @log_entry.update!(log_entry_params)
    render json: @log_entry, status: :ok
  end

  def destroy
    log_entry = Log.find(params['log_id']).log_entries.find(params['id'])
    log_entry.destroy!
    render json: log_entry
  end

  def index
    log_id = params['log_id']

    if log_id.present?
      render json: ActiveModel::Serializer::CollectionSerializer.new(
        current_user.logs.find(log_id).log_entries_ordered,
        each_serializer: LogEntrySerializer,
      )
    else
      all_log_entries =
        current_user.logs.
          includes(:number_log_entries_ordered, :text_log_entries_ordered).
          map do |log|
            {
              log_id: log.id,
              log_entries:
                ActiveModel::Serializer::CollectionSerializer.new(
                  log.log_entries_ordered,
                  each_serializer: LogEntrySerializer,
                ).to_a,
            }
          end
      # `to_json` is necessary to avoid warning in logs.
      # see https://github.com/rails-api/active_model_serializers/issues/2024
      render json: all_log_entries.to_json
    end
  end
end
