class Test::Tasks::CreateDbCopies < Pallets::Task
  include Test::TaskHelpers

  def run
    # The commands below will error if there are any active connections to the
    # database, so disconnect.
    ActiveRecord::Base.connection_pool.connections.each(&:disconnect!)
    sleep(0.1)

    postgres_host = ENV.fetch('POSTGRES_HOST', 'localhost')
    postgres_user = ENV.fetch('POSTGRES_USER', 'david_runger')

    %w[unit api html feature_a feature_c].each do |db_suffix|
      db_name = "david_runger_test_#{db_suffix}"

      # in CI, we know that the database doesn't exist, so don't waste any time dropping it
      unless ENV.key?('CI')
        execute_system_command("dropdb --if-exists #{db_name}")
      end

      execute_system_command(<<~COMMAND)
        createdb
          -T david_runger_test #{db_name}
          -h #{postgres_host}
          -U #{postgres_user}
          --no-password
      COMMAND
    end
  end
end
