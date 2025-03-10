class Test::Tasks::RunFeatureTestsC < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_feature_c CAPYBARA_SERVER_PORT=3003
      bin/rspec $(cat tmp/feature_specs_c.txt)
      --format failures --format progress --force-color
    COMMAND
  end
end
