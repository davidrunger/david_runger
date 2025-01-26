class Test::Tasks::RunVitest < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(
      './node_modules/.bin/vitest run',
      log_stdout_only_on_failure: true,
    )
  end
end
