# frozen_string_literal: true

class Test::Tasks::YarnInstall < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('yarn install')
  end
end
