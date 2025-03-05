class Test::Tasks::RunRubocop < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      bin/rubocop $(git ls-files) --color --format clang --force-exclusion --cache=false
    COMMAND
  end
end
