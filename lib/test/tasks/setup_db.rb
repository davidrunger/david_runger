class Test::Tasks::SetupDb < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rake_task('db:create', 'DISABLE_TYPELIZER=1')
    execute_rake_task('db:environment:set', 'RAILS_ENV=test')
    execute_rake_task('db:schema:load')
  end
end
