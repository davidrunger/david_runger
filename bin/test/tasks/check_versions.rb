# frozen_string_literal: true

class Test::Tasks::CheckVersions < Pallets::Task
  include Test::TaskHelpers

  def run
    ruby_version = File.read('.ruby-version').rstrip
    execute_system_command(<<~COMMAND)
      ruby --version && [ "$(ruby --version | cut -c1-11)" = 'ruby #{ruby_version} ' ]
    COMMAND

    node_version = File.read('.nvmrc').rstrip
    execute_system_command(<<~COMMAND)
      node --version && [ "$(node --version)" = '#{node_version}' ]
    COMMAND

    pnpm_version = JSON.parse(File.read('package.json'))['packageManager'].delete_prefix('pnpm@')
    execute_system_command(<<~COMMAND)
      pnpm --version && [ "$(pnpm --version)" = '#{pnpm_version}' ]
    COMMAND
  end
end
