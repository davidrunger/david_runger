# frozen_string_literal: true

class Test::Tasks::RunEslint < Pallets::Task
  def run
    execute_system_command(<<~COMMAND)
      ./node_modules/.bin/eslint --max-warnings 0 --ext .js,.vue app/javascript/
    COMMAND
  end
end
