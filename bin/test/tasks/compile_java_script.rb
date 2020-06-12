# frozen_string_literal: true

class Test::Tasks::CompileJavaScript < Pallets::Task
  def run
    execute_system_command('bin/webpack --silent')
  end
end
