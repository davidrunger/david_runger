# frozen_string_literal: true

class Api::LogEntriesController < ApplicationController
  def create
    authorize(LogEntry)
    log = (current_user || auth_token_user).logs.find(params.dig(:log_entry, :log_id))
    @log_entry = log.log_entries.build(log_entry_params)
    if @log_entry.valid?
      LogEntries::Save.run!(log_entry: @log_entry)
      render json: @log_entry, status: :created
    else
      render json: { errors: @log_entry.errors.to_hash }, status: :unprocessable_entity
    end
  end

  # currently only works for `TextLogEntry`s
  def update
    @log_entry ||= current_user.text_log_entries.find_by(id: params['id'])
    if @log_entry.nil?
      head(404)
      skip_authorization
      return
    end

    authorize(@log_entry)
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

    log_entry_json_strings =
      if log_id.present?
        log = Log.find(log_id)
        authorize(log, :show?)
        log_entry_json_strings_for_log(log)
      else
        log_entry_json_strings_for_user_and_table(
          user: current_user,
          table_name: LogEntries::NumberLogEntry.table_name,
        ) +
          log_entry_json_strings_for_user_and_table(
            user: current_user,
            table_name: LogEntries::TextLogEntry.table_name,
          )
      end

    render(json: "[#{log_entry_json_strings.join(',')}]")
  end

  private

  def log_entry_params
    params.require(:log_entry).permit(:created_at, :data, :note)
  end

  def log_entry_json_strings_for_log(log)
    ActiveRecord::Base.connection.select_values(<<~SQL.squish)
      SELECT row_to_json(log_entry)
      FROM (
        SELECT
          id,
          to_char(created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS created_at,
          data,
          log_id,
          note
        FROM #{log.log_entries_table_name}
        WHERE #{log.log_entries_table_name}.log_id = #{log.id}
      ) log_entry;
    SQL
  end

  def log_entry_json_strings_for_user_and_table(user:, table_name:)
    ActiveRecord::Base.connection.select_values(<<~SQL.squish)
      SELECT row_to_json(log_entry)
      FROM (
        SELECT
          #{table_name}.id,
          to_char(
            #{table_name}.created_at AT TIME ZONE 'UTC',
            'YYYY-MM-DD"T"HH24:MI:SS"Z"'
          ) AS created_at,
          #{table_name}.data,
          #{table_name}.log_id,
          #{table_name}.note
        FROM #{table_name}
        INNER JOIN logs ON logs.id = #{table_name}.log_id
        WHERE logs.user_id = #{user.id}
      ) log_entry;
    SQL
  end
end
