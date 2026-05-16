class Test::Tasks::SetupDb < Pallets::Task
  include Test::TaskHelpers

  def run
    # Drop the database when running locally to avoid error about pghero schema already existing.
    if ENV.fetch('CI', false).blank?
      execute_rake_task('db:environment:set')
      execute_rake_task('db:drop')
    end

    execute_rake_task('db:create')
    execute_rake_task('db:environment:set')
    execute_rake_task('db:schema:load')
  end
end
