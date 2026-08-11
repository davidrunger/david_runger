class Test::Tasks::RunApiControllerTests < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_api
      COVERAGE_RESULTSET_NAME=api_controller
      bin/rspec
      spec/controllers/api/
      #{rspec_output_options}
    COMMAND
  end
end
