class Test::Tasks::ConvertSchemasToTs < Pallets::Task
  include Test::TaskHelpers

  def run
    puts("#{AmazingPrint::Colors.yellow('Writing JSON schemas as types')} ...")

    JsonSchemasToTypescript.write_files

    if execute_system_command('git diff --exit-code')
      record_success_and_log_message('Wrote JSON schemas as types.')
    else
      # Reset the git state, so it's clean for other test tasks.
      execute_system_command('git checkout .')

      record_failure_and_log_message(<<~LOG)
        There was a git diff after converting JSON schemas to types.
      LOG
    end
  end
end
