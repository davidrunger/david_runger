class Test::Tasks::RunRubocop < Pallets::Task
  include Test::TaskHelpers

  def run
    `git status --ignored --porcelain`.lines.grep(/^!! /)

    execute_system_command(<<~COMMAND)
      bin/rubocop --color --format tap
    COMMAND
  end
end
