class Test::Tasks::SetupDb < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rake_task('db:create')
    execute_rake_task('db:environment:set')
    execute_rake_task('db:schema:load')
  end
end
