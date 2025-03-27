class Test::Tasks::ConvertSchemasToTs < Pallets::Task
  include Test::TaskHelpers

  def run
    puts("Executing #{AmazingPrint::Colors.yellow('JsonSchemasToTypescript.write_files')} ...")

    JsonSchemasToTypescript.write_files

    if execute_system_command('git diff --exit-code')
      record_success_and_log_message('JsonSchemasToTypescript.write_files completed successfully.')
    else
      # Reset the git state, so it's clean for other test tasks.
      execute_system_command('git checkout .')

      record_failure_and_log_message(<<~LOG)
        There was a git diff after converting JSON schemas to types.
      LOG
    end
  end
end
