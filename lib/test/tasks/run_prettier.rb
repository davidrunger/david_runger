# frozen_string_literal: true

class Test::Tasks::RunPrettier < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(
      './node_modules/.bin/prettier . --check',
    )
  end
end
