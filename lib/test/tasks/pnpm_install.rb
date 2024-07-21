class Test::Tasks::PnpmInstall < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(
      'pnpm install --frozen-lockfile --loglevel=warn',
      log_stdout_only_on_failure: true,
    )
  end
end
