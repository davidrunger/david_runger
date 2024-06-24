# frozen_string_literal: true

class Test::Tasks::PnpmInstall < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('pnpm install --frozen-lockfile --silent')
  end
end
