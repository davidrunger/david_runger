# frozen_string_literal: true

class Api::LogEntriesController < ApplicationController
  include TokenAuthenticatable

  # For #create, we can also authenticate via an `auth_token` param. If no `auth_token` param is
  # present, then we will authenticate a current_user and run verify_authenticity_token.
  skip_before_action :authenticate_user, only: %i[create]
  skip_before_action :verify_authenticity_token, only: %i[create]

  def create
    if auth_token_param_present?
      verify_valid_auth_token!
    else
      verify_authenticity_token
      if current_user.blank?
        raise('User must be logged in to access api/log_entries#create without an auth_token')
      end
    end

    log = (current_user || auth_token_user).logs.find(params.dig(:log_entry, :log_id))
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
