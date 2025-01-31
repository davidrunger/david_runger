class Test::Tasks::CheckVersions < Pallets::Task
  include Test::TaskHelpers

  def run
    ruby_version = File.read('.ruby-version').rstrip
    execute_system_command(<<~COMMAND)
      ruby --version && [ "$(ruby --version | cut -c1-11)" = 'ruby #{ruby_version} ' ]
    COMMAND

    node_version = File.read('.node-version').rstrip
    execute_system_command(<<~COMMAND)
      node --version && [ "$(node --version)" = 'v#{node_version}' ]
    COMMAND

    pnpm_version_specification = JSON.parse(File.read('package.json')).dig('engines', 'pnpm')
    puts("Specified pnpm version/range: #{pnpm_version_specification}")
    # Log only; don't check that it is within the range (since that would be a bit complex).
    execute_system_command(<<~COMMAND)
      pnpm --version
    COMMAND
  end
end
