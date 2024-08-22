class Test::Tasks::RunTypelizer < Pallets::Task
  include Test::TaskHelpers

  def run
    pp(Rake::Task.tasks)
    begin
      execute_rake_task('typelizer:generate')
    rescue => error
      pp(error)
      puts(error.backtrace)
    end
    execute_system_command("! grep --quiet -RP '\\bunknown\\b' app/javascript/types/serializers/")
    execute_system_command('git diff --exit-code')
  end
end
