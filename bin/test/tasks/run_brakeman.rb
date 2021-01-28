# frozen_string_literal: true

class Test::Tasks::RunBrakeman < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('bin/brakeman --quiet --no-pager')
  end
end
