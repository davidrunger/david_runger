class Test::Tasks::RunOxlint < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      ./node_modules/.bin/oxlint app/javascript/ --max-warnings 0
    COMMAND
  end
end
