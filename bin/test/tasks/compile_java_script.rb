# frozen_string_literal: true

class Test::Tasks::CompileJavaScript < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('bin/webpack')
  end
end
