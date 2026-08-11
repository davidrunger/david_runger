class Test::Tasks::RunFeatureTestsC < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_feature_c CAPYBARA_SERVER_PORT=3003
      COVERAGE_RESULTSET_NAME=feature_c
      bin/rspec $(cat tmp/feature_specs_c.txt)
      #{rspec_output_options}
    COMMAND
  end
end
