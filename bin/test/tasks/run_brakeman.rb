# frozen_string_literal: true

class Test::Tasks::RunBrakeman < Pallets::Task
  def run
    execute_system_command('bin/brakeman --quiet')
  end
end
