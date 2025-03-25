class Api::LogEntriesController < Api::BaseController
  allow_auth_token_authorization

  skip_before_action :authenticate_user!, only: %i[index]

  def create
    authorize(LogEntry)
    log = (current_user || auth_token_user).logs.find(params.dig(:log_entry, :log_id))
    @log_entry = log.build_log_entry_with_datum(log_entry_params)

    if @log_entry.valid?
      LogEntries::Save.run!(log_entry: @log_entry)
      render_schema_json(@log_entry, status: :created)
    else
      render json: { errors: @log_entry.errors.to_hash }, status: :unprocessable_entity
    end
  end

  def update
    @log_entry ||= current_user.log_entries.find_by(id: params['id'])

    if @log_entry.nil?
      head(:not_found)
      skip_authorization
      return
    end

    authorize(@log_entry)

    if LogEntries::Update.new!(log_entry: @log_entry, params: log_entry_params).run.success?
      render_schema_json(@log_entry, status: :ok)
    else
      render json: { errors: @log_entry.errors.to_hash }, status: :unprocessable_entity
    end
  end

  def destroy
    @log_entry =
      current_user.logs.find_by(id: params['log_id'])&.
        log_entries&.find_by(id: params['id'])
    if @log_entry.nil?
      head(:not_found)
      skip_authorization
      return
    end

    authorize(@log_entry)
    @log_entry.destroy!
    head(:no_content)
  end

  def index
    log_id = params['log_id']

    log_entry_json_strings =
      if log_id.present?
        log = Log.find(log_id)

        authorize(log, :show?)

        if !log.publicly_viewable?
          authenticate_user!
        end

        log_entry_json_strings_for_log(log)
      else
        authenticate_user!
        authorize(LogEntry)

        log_entry_json_strings_for_user_and_datum_class(
          user: current_user,
          datum_class: NumberLogEntryDatum,
        ) +
          log_entry_json_strings_for_user_and_datum_class(
            user: current_user,
            datum_class: TextLogEntryDatum,
          )
      end

    render_schema_json("[#{log_entry_json_strings.join(',')}]")
  end

  private

  def log_entry_params
    params.expect(log_entry: %i[created_at data note])
  end

  def log_entry_json_strings_for_log(log)
    datum_class = log.log_entry_datum_class
    datum_table_name = datum_class.table_name
    datum_class_name = datum_class.name

    ApplicationRecord.with_connection do |connection|
      connection.select_values(<<~SQL.squish)
        SELECT row_to_json(log_entry)
        FROM (
          SELECT
            log_entries.id,
            to_char(log_entries.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS created_at,
            data,
            log_entries.log_id,
            log_entries.note
          FROM #{datum_table_name}
          INNER JOIN log_entries
            ON log_entries.log_entry_datum_id = #{datum_table_name}.id
            AND log_entries.log_entry_datum_type = '#{datum_class_name}'
          WHERE log_entries.log_id = #{log.id}
        ) log_entry;
      SQL
    end
  end

  def log_entry_json_strings_for_user_and_datum_class(user:, datum_class:)
    datum_table_name = datum_class.table_name
    datum_class_name = datum_class.name

    ApplicationRecord.with_connection do |connection|
      connection.select_values(<<~SQL.squish)
        SELECT row_to_json(log_entry)
        FROM (
          SELECT
            log_entries.id,
            to_char(
              log_entries.created_at AT TIME ZONE 'UTC',
              'YYYY-MM-DD"T"HH24:MI:SS"Z"'
            ) AS created_at,
            #{datum_table_name}.data,
            log_entries.log_id,
            log_entries.note
          FROM #{datum_table_name}
          INNER JOIN log_entries
            ON log_entries.log_entry_datum_id = #{datum_table_name}.id
            AND log_entries.log_entry_datum_type = '#{datum_class_name}'
          INNER JOIN logs
            ON logs.id = log_entries.log_id
          WHERE logs.user_id = #{user.id}
        ) log_entry;
      SQL
    end
  end
end
