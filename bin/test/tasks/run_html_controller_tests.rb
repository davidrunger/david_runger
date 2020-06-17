# frozen_string_literal: true

class Test::Tasks::RunHtmlControllerTests < Pallets::Task
  include Test::TaskHelpers

  def run
    # run all tests in `spec/controllers/` _except_ those in `spec/controllers/api/`
    execute_system_command(<<~COMMAND)
      DB_SUFFIX=_html
      bin/rspec
      $(ls -d spec/controllers/*/ | grep -v 'spec/controllers/api/' | tr '\\n' ' ')
      $(ls spec/controllers/*.rb)
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end
