# frozen_string_literal: true

class Test::Tasks::CreateDbCopies < Pallets::Task
  include Test::TaskHelpers

  def run
    ActiveRecord::Base.remove_connection
    %w[unit api html feature].each do |db_suffix|
      db_name = "david_runger_test_#{db_suffix}"
      # in CI, we know that the database doesn't exist, so don't waste any time dropping it
      unless ENV.key?('CI')
        execute_system_command("dropdb --if-exists #{db_name}")
      end
      execute_system_command(<<~COMMAND)
        createdb
          -T david_runger_test #{db_name}
          -U #{ENV['POSTGRES_USER']}
          -h #{ENV['POSTGRES_HOST']}
          --no-password
      COMMAND
    end
  end
end
