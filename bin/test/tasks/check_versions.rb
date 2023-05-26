# frozen_string_literal: true

class Test::Tasks::CheckVersions < Pallets::Task
  include Test::TaskHelpers

  def run
    ruby_version = File.read('.ruby-version').rstrip
    execute_system_command(<<~COMMAND)
      ruby --version && [ "$(ruby --version | cut -c1-11)" = 'ruby #{ruby_version} ' ]
    COMMAND

    execute_system_command(<<~COMMAND)
      node --version && [ "$(node --version)" = 'v18.12.1' ]
    COMMAND

    execute_system_command(<<~COMMAND)
      yarn --version && [ "$(yarn --version)" = '1.22.19' ]
    COMMAND
  end
end
