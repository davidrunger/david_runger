# frozen_string_literal: true

class Test::Tasks::CheckVersions < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      ruby --version && [ "$(ruby --version | cut -c1-11)" = 'ruby 3.0.2p' ]
    COMMAND
    execute_system_command(<<~COMMAND)
      node --version && [ "$(node --version)" = 'v14.15.0' ]
    COMMAND
    execute_system_command(<<~COMMAND)
      yarn --version && [ "$(yarn --version)" = '1.22.10' ]
    COMMAND
  end
end
