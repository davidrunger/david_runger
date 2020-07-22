# frozen_string_literal: true

class Test::Tasks::CheckVersions < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      ruby --version && [ "$(ruby --version | cut -c1-11)" = 'ruby 2.7.0p' ]
    COMMAND
    execute_system_command(<<~COMMAND)
      bundler --version && [ "$(bundle --version | cut -c1-21)" = 'Bundler version 2.1.2' ]
    COMMAND
    execute_system_command(<<~COMMAND)
      node --version && [ "$(node --version)" = 'v12.13.1' ]
    COMMAND
    execute_system_command(<<~COMMAND)
      yarn --version && [ "$(yarn --version)" = '1.22.4' ]
    COMMAND
  end
end
