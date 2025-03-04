class Test::Tasks::RunUnitTests < Pallets::Task
  include Test::TaskHelpers

  def run
    # Run all tests in `spec/` _except_ those in
    # `spec/{controllers,helpers,requests}/` (which will we run by
    # RunApiControllerTests and RunHtmlControllerTests) and `spec/features/`
    # (which will be run by RunFeatureTests).
    execute_rspec_command(<<~'COMMAND')
      DB_SUFFIX=_unit
      bin/rspec
      $(ls -d spec/*/ |
        grep --extended-regex -v 'spec/(controllers|features|helpers|requests)(/|$)' |
        tr '\n' ' ')
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end
