class Test::Tasks::RunTypelizer < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rake_task('typelizer:generate')
    execute_system_command("! grep --quiet -RP '\\bunknown\\b' app/javascript/types/serializers/")
    execute_system_command('git diff --exit-code')
    execute_system_command('git checkout .') # Reset git state, so it's clean for other test tasks.
  end
end
