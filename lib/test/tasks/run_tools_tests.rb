class Test::Tasks::RunToolsTests < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_unit
      SPEC_GROUP=tools
      bin/rspec
      spec/tools/
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end
