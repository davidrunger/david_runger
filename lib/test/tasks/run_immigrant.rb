# frozen_string_literal: true

class Test::Tasks::RunImmigrant < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rake_task('immigrant:check_keys')
  end
end
