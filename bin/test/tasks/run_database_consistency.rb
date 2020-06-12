# frozen_string_literal: true

class Test::Tasks::RunDatabaseConsistency < Pallets::Task
  def run
    execute_system_command('bin/database_consistency')
  end
end
