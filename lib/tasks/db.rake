# frozen_string_literal: true

module DavidRunger::TruncateTables
  ROW_COUNT_SQL = <<~SQL
    SELECT relname, n_live_tup
    FROM pg_stat_user_tables
    ORDER BY n_live_tup DESC;
  SQL

  def self.max_allowed_rows
    Integer(ENV.fetch('MAX_TABLE_ROWS') { 2_000 })
  end

  def self.print_row_counts
    ApplicationRecord.connection.execute('ANALYZE')
    ApplicationRecord.connection.execute(ROW_COUNT_SQL).to_a.each do |row|
      puts "#{row['n_live_tup']} rows - #{row['relname']}"
    end
  end

  def self.truncate(table:, timestamp:)
    num_rows =
      ApplicationRecord.connection.execute("SELECT count(*) FROM #{table}").to_a.first['count']
    puts "Rows in `#{table}` prior to truncation: #{num_rows}"

    min_surviving_timestamp_sql = <<~SQL
      SELECT #{timestamp}
      FROM #{table}
      ORDER BY #{timestamp} DESC
      LIMIT #{max_allowed_rows}
    SQL

    min_surviving_timestamp =
      ApplicationRecord.connection.execute(min_surviving_timestamp_sql).to_a.last[timestamp]
    delete_old_rows_sql = <<~SQL
      DELETE
      FROM #{table}
      WHERE #{timestamp} < '#{min_surviving_timestamp}'
    SQL
    ApplicationRecord.connection.execute(delete_old_rows_sql)
    puts "Deleted rows older than #{min_surviving_timestamp} (database time, probably UTC)"
    num_rows =
      ApplicationRecord.connection.execute("SELECT count(*) FROM #{table}").to_a.first['count']
    puts "Rows in `#{table}` after truncation: #{num_rows}"
    puts
  end
end

namespace :db do
  desc 'Delete all but the most recent rows in our larger tables'
  task truncate_tables: :environment do
    puts "About to truncate database tables; max is #{DavidRunger::TruncateTables.max_allowed_rows}"

    puts 'Approximate row counts prior to deletion:'
    DavidRunger::TruncateTables.print_row_counts
    puts

    DavidRunger::TruncateTables.truncate(table: 'requests', timestamp: 'requested_at')
    DavidRunger::TruncateTables.truncate(table: 'pghero_query_stats', timestamp: 'captured_at')
    DavidRunger::TruncateTables.truncate(table: 'pghero_space_stats', timestamp: 'captured_at')

    puts 'Done truncating tables'
  end
end
