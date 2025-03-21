class Test::Tasks::RunFeatureTestsA < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_feature_a CAPYBARA_SERVER_PORT=3001
      bin/rspec $(cat tmp/feature_specs_a.txt)
      #{rspec_output_options}
    COMMAND
  end
end
