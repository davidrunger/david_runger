# frozen_string_literal: true

class TruncateTables
  include Sidekiq::Worker

  ROW_COUNT_SQL = <<~SQL
    SELECT relname, n_live_tup
    FROM pg_stat_user_tables
    ORDER BY n_live_tup DESC;
  SQL

  def self.max_allowed_rows
    Integer(ENV.fetch('MAX_TABLE_ROWS') { 1_500 })
  end

  def self.print_row_counts
    ApplicationRecord.connection.execute('ANALYZE')
    ApplicationRecord.connection.execute(ROW_COUNT_SQL).to_a.each do |row|
      Rails.logger.info("#{row['n_live_tup']} rows - #{row['relname']}")
    end
  end

  def self.truncate(table:, timestamp:)
    num_rows =
      ApplicationRecord.connection.execute("SELECT count(*) FROM #{table}").to_a.first['count']
    Rails.logger.info("Rows in `#{table}` prior to truncation: #{num_rows}")

    min_surviving_timestamp_sql = <<~SQL
      SELECT #{timestamp}
      FROM #{table}
      ORDER BY #{timestamp} DESC
      LIMIT #{max_allowed_rows}
    SQL

    min_surviving_timestamp =
      ApplicationRecord.connection.execute(min_surviving_timestamp_sql).to_a.last&.dig(timestamp)
    return if min_surviving_timestamp.nil?

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

  def perform
    Rails.logger.info(<<~LOG.squish)
      About to truncate database tables;
      max allowed rows is #{self.class.max_allowed_rows}
    LOG

    Rails.logger.info('Approximate row counts prior to deletion:')
    self.class.print_row_counts
    Rails.logger.info

    self.class.truncate(table: 'requests', timestamp: 'requested_at')

    Rails.logger.info('Done truncating tables')
  end
end
