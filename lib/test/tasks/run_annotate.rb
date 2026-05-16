class Test::Tasks::RunAnnotate < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      bin/annotaterb models
    COMMAND

    if !execute_system_command('git diff --exit-code -- . ":(exclude)app/javascript/"')
      # Reset the git state, so it's clean for other test tasks.
      execute_system_command('git checkout -- . ":(exclude)app/javascript/"')
    end
  end
end
