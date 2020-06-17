# frozen_string_literal: true

class Test::Tasks::RunFeatureTests < Pallets::Task
  include Test::TaskHelpers

  def run
    # run all tests in `spec/features/` (wrapped by percy, if PERCY_TOKEN is present)
    execute_system_command(<<~COMMAND)
      DB_SUFFIX=_feature
      #{'./node_modules/.bin/percy exec -- ' if ENV['PERCY_TOKEN'].present?}
      bin/rspec spec/features/
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end
