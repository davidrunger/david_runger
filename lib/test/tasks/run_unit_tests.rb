class Test::Tasks::RunUnitTests < Pallets::Task
  include Test::TaskHelpers

  def run
    # Run all tests in `spec/` _except_ those in `spec/controllers/` and `spec/features/`.
    # Tests in `spec/controllers/` will be run by RunApiControllerTests and RunHtmlControllerTests.
    # Tests in `spec/features/` will be run by RunFeatureTests task(s).
    execute_rspec_command(<<~'COMMAND')
      DB_SUFFIX=_unit
      bin/rspec
      $(ls -d spec/*/ |
        grep --extended-regex -v 'spec/(controllers|features|helpers)(/|$)' |
        tr '\n' ' ')
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end
