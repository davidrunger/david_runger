class Test::Tasks::CreateDbCopies < Pallets::Task
  include Test::TaskHelpers

  # rubocop:disable Metrics
  def run
    # The commands below will error if there are any active connections to the
    # database, so disconnect.
    active_statuses = ActiveRecord::Base.connection_pool.connections.map(&:active?)
    attempts = 50
    attempts.times do |index|
      logger.info(%(active_statuses: #{active_statuses}))

      if active_statuses.any?
        ActiveRecord::Base.connection_pool.connections.each(&:disconnect!)
        sleep(0.1)
        active_statuses = ActiveRecord::Base.connection_pool.connections.map(&:active?)
      else
        break
      end

      if index == attempts - 1
        fail 'Exhausted attempts to disconnect!'
      end
    end

    %w[unit api html feature_a feature_c].each do |db_suffix|
      db_name = "david_runger_test_#{db_suffix}"

      # in CI, we know that the database doesn't exist, so don't waste any time dropping it
      unless ENV.key?('CI')
        execute_system_command("dropdb --if-exists #{db_name}")
      end

      execute_system_command(<<~COMMAND.squish)
        psql -U postgres -h 127.0.0.1 -d david_runger_test -c "
        SELECT pid, usename, application_name, client_addr, state, query
        FROM pg_stat_activity
        WHERE datname = 'david_runger_test' AND pid != pg_backend_pid();"
      COMMAND

      execute_system_command(<<~COMMAND)
        createdb
          -T david_runger_test #{db_name}
          -U #{ENV.fetch('POSTGRES_USER', 'david_runger')}
          -h #{ENV.fetch('POSTGRES_HOST', 'localhost')}
          --no-password
      COMMAND
    end
  end
  # rubocop:enable Metrics
end
