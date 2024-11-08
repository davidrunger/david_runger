class Test::Tasks::RunAnnotate < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      bin/annotaterb --models --show-indexes --sort --exclude fixtures,tests
    COMMAND

    if !execute_system_command('git diff --exit-code')
      # Reset the git state, so it's clean for other test tasks.
      execute_system_command('git checkout .')
    end
  end
end
