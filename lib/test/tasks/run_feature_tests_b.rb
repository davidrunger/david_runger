class Test::Tasks::RunFeatureTestsB < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_api CAPYBARA_SERVER_PORT=3002
      COVERAGE_RESULTSET_NAME=feature_b
      bin/rspec $(cat tmp/feature_specs_b.txt)
      #{rspec_output_options}
    COMMAND
  end
end
