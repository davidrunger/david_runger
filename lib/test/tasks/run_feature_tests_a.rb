class Test::Tasks::RunFeatureTestsA < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_feature CAPYBARA_SERVER_PORT=3001
      #{'./node_modules/.bin/percy exec --port 5338 -- ' if ENV['PERCY_TOKEN'].present?}
      bin/rspec $(cat tmp/feature_specs_a.txt)
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end
