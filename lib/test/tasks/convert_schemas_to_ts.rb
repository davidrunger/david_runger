class Test::Tasks::ConvertSchemasToTs < Pallets::Task
  include Test::TaskHelpers

  def run
    run_ruby_code(
      task_description: 'JsonSchemasToTypescript.write_files',
      success_check: -> { execute_system_command('git diff --exit-code') },
      # Reset the git state, so it's clean for other test tasks.
      on_failure: -> { execute_system_command('git checkout .') },
      failure_message: 'There was a git diff after converting JSON schemas to types.',
    ) do
      JsonSchemasToTypescript.write_files
    end
  end
end
