class Test::Tasks::RunApiControllerTests < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_api
      bin/rspec
      spec/controllers/api/
      --format progress --force-color
    COMMAND
  end
end
