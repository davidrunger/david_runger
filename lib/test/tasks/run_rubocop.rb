class Test::Tasks::RunRubocop < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      bundle exec rubocop --color --format clang
    COMMAND
  end
end
