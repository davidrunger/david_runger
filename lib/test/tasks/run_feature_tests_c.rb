class Test::Tasks::RunFeatureTestsC < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_unit CAPYBARA_SERVER_PORT=3003
      #{'./node_modules/.bin/percy exec -- ' if ENV['PERCY_TOKEN'].present?}
      bin/rspec $(cat tmp/feature_specs_c.txt)
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end
