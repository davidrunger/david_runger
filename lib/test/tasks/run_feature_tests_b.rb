class Test::Tasks::RunFeatureTestsB < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_api CAPYBARA_SERVER_PORT=3002
      bin/rspec $(cat tmp/feature_specs_b.txt)
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end
