class Test::Tasks::RunTypelizer < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rake_task('typelizer:generate')
    execute_system_command("! grep --quiet -RP '\\bunknown\\b' app/javascript/types/serializers/")

    if !execute_system_command('git diff --exit-code')
      # Reset the git state, so it's clean for other test tasks.
      execute_system_command('git checkout .')
    end
  end
end
