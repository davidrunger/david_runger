require Rails.root.join('lib/json_schemas_to_typescript.rb')

class Test::Tasks::ConvertSchemasToTs < Pallets::Task
  include Test::TaskHelpers

  def run
    puts("Running '#{AmazingPrint::Colors.yellow(self.class.name)}' ...")

    time =
      Benchmark.measure do
        JsonSchemasToTypescript.write_files
      end.real

    if execute_system_command('test -z "$(git status --porcelain)"')
      record_success_and_log_message("'#{self.class.name}' succeeded (took #{time.round(3)}).")
    else
      execute_system_command('git diff')
      # Reset the git state, so it's clean for other test tasks.
      execute_system_command('git checkout .', log_stdout_only_on_failure: true)
      record_failed_command('bin/json-schemas-to-typescript')
      record_failure_and_log_message(<<~LOG.squish)
        Executing JsonSchemasToTypescript.write_files introduced a diff.
      LOG
    end
  end
end
