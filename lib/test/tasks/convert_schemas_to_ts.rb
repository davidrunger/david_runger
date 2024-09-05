class Test::Tasks::ConvertSchemasToTs < Pallets::Task
  include Test::TaskHelpers

  def run
    if !execute_system_command(<<~COMMAND)
      bin/json-schemas-to-typescript && git diff --exit-code
    COMMAND
      # Reset the git state, so it's clean for other test tasks.
      execute_system_command('git checkout .')
    end
  end
end
