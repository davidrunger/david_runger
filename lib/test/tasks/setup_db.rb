class Test::Tasks::SetupDb < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rake_task('db:create', env_vars: { 'DISABLE_TYPELIZER' => '1' })
    execute_rake_task('db:environment:set')
    execute_rake_task('db:schema:load')
  end
end
