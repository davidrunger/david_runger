# frozen_string_literal: true

class Test::Tasks::InstallYarn < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('npm install -g yarn@1.22.10')
  end
end
