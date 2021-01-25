# frozen_string_literal: true

class Api::LogEntriesController < ApplicationController
  def create
    authorize(LogEntry)

    if log_entry_params[:data].present?
      log = (current_user || auth_token_user).logs.find(params.dig(:log_entry, :log_id))
      log_entry = LogEntries::Create.new(log: log, attributes: log_entry_params).run!.log_entry
      render json: log_entry, status: :created
    else
      render json: { errors: 'No data value was provided' }, status: :unprocessable_entity
    end
  end

  def update
    @log_entry ||= current_user.log_entries.find_by(id: params['id'])
    if @log_entry.nil?
      head(404)
      skip_authorization
      return
    end

    authorize(@log_entry)
    if @log_entry.data_logable.update(value: log_entry_params[:data])
      render json: @log_entry, status: :ok
    else
      render json: { errors: @log_entry.data_logable.errors.to_hash }, status: :unprocessable_entity
    end
  end

  def destroy
    @log_entry =
      current_user.
        logs.find_by(id: params['log_id'])&.
        log_entries&.find_by(id: params['id'])
    if @log_entry.nil?
      head(404)
      skip_authorization
      return
    end

    authorize(@log_entry)
    @log_entry.destroy!
    head(204)
  end

  def index
    authorize(LogEntry)
    log_id = params['log_id']

    log_entries =
      if log_id.present?
        log = Log.find(log_id)
        authorize(log, :show?)
        log.log_entries.includes(:data_logable)
      else
        logs = current_user.logs.includes(log_entries: :data_logable).to_a
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
    params.require(:log_entry).permit(:created_at, :data, :note)
  end
end
