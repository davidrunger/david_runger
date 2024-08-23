class Test::Tasks::ConvertSchemasToTs < Pallets::Task
  include Test::TaskHelpers

  def run
    puts("Running '#{AmazingPrint::Colors.yellow(self.class.name)}' ...")

    if !execute_system_command(<<~COMMAND)
      bin/json-schemas-to-typescript && test -z "$(git status --porcelain)"
    COMMAND
      execute_system_command('git diff')
      # Reset the git state, so it's clean for other test tasks.
      execute_system_command('git checkout .')
    end
  end
end
