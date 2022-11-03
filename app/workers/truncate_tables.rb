# frozen_string_literal: true

class TruncateTables
  prepend ApplicationWorker

  ROW_COUNT_SQL = <<~SQL.squish
    SELECT relname, n_live_tup
    FROM pg_stat_user_tables
    ORDER BY n_live_tup DESC;
  SQL

  def self.max_allowed_rows
    Integer(ENV.fetch('MAX_TABLE_ROWS', 10_000))
  end

  def self.print_row_counts
    ApplicationRecord.connection.execute(ROW_COUNT_SQL).to_a.each do |row|
      Rails.logger.info("#{row['n_live_tup']} rows - #{row['relname']}")
    end
  end

  def self.truncate(
    table:,
    timestamp:,
    max_allowed_rows: self.max_allowed_rows,
    min_surviving_timestamp: nil
  )
    log_truncation_plan(table:, max_allowed_rows:, min_surviving_timestamp:)

    num_rows =
      ApplicationRecord.connection.execute("SELECT count(*) FROM #{table}").to_a.first['count']
    Rails.logger.info("Rows in `#{table}` prior to truncation: #{num_rows}")

    min_surviving_timestamp_sql = <<~SQL.squish
      SELECT #{timestamp}
      FROM #{table}
      ORDER BY #{timestamp} DESC
      LIMIT #{max_allowed_rows}
    SQL

    min_surviving_timestamp_based_on_count =
      ApplicationRecord.connection.execute(min_surviving_timestamp_sql).to_a.last&.dig(timestamp)
    return if min_surviving_timestamp_based_on_count.nil?

    min_surviving_timestamp =
      [min_surviving_timestamp_based_on_count, min_surviving_timestamp].compact.max

    delete_old_rows_sql = <<~SQL.squish
      DELETE
      FROM #{table}
      WHERE #{timestamp} < '#{min_surviving_timestamp}'
    SQL
    ApplicationRecord.connection.execute(delete_old_rows_sql)
    Rails.logger.info(
      "Deleted rows older than #{min_surviving_timestamp} (database time, probably UTC)",
    )
    num_rows =
      ApplicationRecord.connection.execute("SELECT count(*) FROM #{table}").to_a.first['count']
    Rails.logger.info("Rows in `#{table}` after truncation: #{num_rows}")
  end

  def self.log_truncation_plan(table:, max_allowed_rows:, min_surviving_timestamp:)
    if min_surviving_timestamp.present?
      Rails.logger.info(<<~LOG.squish)
        Truncating `#{table}` with a minimum surviving timestamp of #{min_surviving_timestamp} and
        #{max_allowed_rows} rows (whichever leaves fewer rows in the table).
      LOG
    else
      Rails.logger.info("Truncating `#{table}` with a max of #{max_allowed_rows} rows.")
    end
  end

  def perform
    Rails.logger.info('About to truncate database tables.')

    Rails.logger.info('Approximate row counts prior to deletion:')
    self.class.print_row_counts
    Rails.logger.info

    self.class.truncate(table: 'requests', timestamp: 'requested_at')
    self.class.truncate(
      table: 'ip_blocks',
      timestamp: 'created_at',
      min_surviving_timestamp: 2.weeks.ago,
    )

    Rails.logger.info('Done truncating tables')
  end
end
