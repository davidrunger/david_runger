# frozen_string_literal: true

class Test::Tasks::CheckVersions < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      ruby --version && [ "$(ruby --version | cut -c1-11)" = 'ruby 3.1.3p' ]
    COMMAND
    execute_system_command(<<~COMMAND)
      node --version && [ "$(node --version)" = 'v18.9.1' ]
    COMMAND
    execute_system_command(<<~COMMAND)
      yarn --version && [ "$(yarn --version)" = '1.22.19' ]
    COMMAND
  end
end
