# frozen_string_literal: true

class Api::LogEntriesController < ApplicationController
  def create
    log = current_user.logs.find(params.dig(:log_entry, :log_id))
    @log_entry = log.log_entries.build(log_entry_params)
    if @log_entry.save
      render json: @log_entry, status: :created
    else
      render json: { errors: @log_entry.errors.to_hash }, status: :unprocessable_entity
    end
  end

  # currently only works for `TextLogEntry`s
  def update
    @log_entry ||= current_user.text_log_entries.find_by(id: params['id'])
    head(404) && return if @log_entry.nil?

    if @log_entry.update(log_entry_params)
      render json: @log_entry, status: :ok
    else
      render json: { errors: @log_entry.errors.to_hash }, status: :unprocessable_entity
    end
  end

  def destroy
    @log_entry =
      current_user.
        logs.find_by(id: params['log_id'])&.
        log_entries&.find_by(id: params['id'])
    head(404) && return if @log_entry.nil?

    @log_entry.destroy!
    head(204)
  end

  def index
    log_id = params['log_id']

    log_entries =
      if log_id.present?
        log = Log.find(log_id)
        authorize(log, :show?)
        log.log_entries
      else
        logs =
          current_user.logs.
            includes(:number_log_entries, :text_log_entries).
            to_a
        logs.map!(&:log_entries).flatten!
        logs
      end

    render json: ActiveModel::Serializer::CollectionSerializer.new(
      log_entries,
      serializer: LogEntrySerializer,
    )
  end

  private

  def log_entry_params
    params.require(:log_entry).permit(:data, :note)
  end
end
