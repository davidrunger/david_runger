class Test::Tasks::RunToolsTests < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_unit
      COVERAGE_RESULTSET_NAME=tools
      bin/rspec
      spec/tools/
      #{rspec_output_options}
    COMMAND
  end
end
