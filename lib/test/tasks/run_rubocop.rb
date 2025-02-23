class Test::Tasks::RunRubocop < Pallets::Task
  include Test::TaskHelpers

  def run
    # bin/rubocop --color --format clang
    execute_system_command(<<~COMMAND)
      echo 'Temporarily disabled due to bugs (?) in RuboCop.'
    COMMAND
  end
end
