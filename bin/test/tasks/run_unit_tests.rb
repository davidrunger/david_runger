# frozen_string_literal: true

class Test::Tasks::RunUnitTests < Pallets::Task
  include Test::TaskHelpers

  def run
    # run all tests in `spec/` _except_ those in `spec/controllers/` that are _not_ in
    # `spec/controllers/api/` and those in `spec/features/`
    execute_system_command(<<~COMMAND)
      bin/rspec
      $(ls -d spec/*/ | grep --extended-regex -v 'spec/(controllers|features)/' | tr '\\n' ' ')
      spec/controllers/api/
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end
