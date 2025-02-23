class Test::Tasks::RunRubocop < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      bin/rubocop --color --force-exclusion --format clang
    COMMAND
  end
end
