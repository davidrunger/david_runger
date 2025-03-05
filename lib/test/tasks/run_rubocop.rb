class Test::Tasks::RunRubocop < Pallets::Task
  include Test::TaskHelpers

  def run
    puts('Paths to be excluded by RuboCop:')
    pp(`git status --ignored --porcelain`.lines.grep(/^!! /))

    execute_system_command(<<~COMMAND)
      bin/rubocop --color --format tap
    COMMAND
  end
end
