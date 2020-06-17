# frozen_string_literal: true

class Test::Tasks::RunApiControllerTests < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      DB_SUFFIX=_api
      bin/rspec
      spec/controllers/api/
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end
