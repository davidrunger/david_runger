# frozen_string_literal: true

class Test::Tasks::EnsureLatestChromedriver < Pallets::Task
  include Test::TaskHelpers

  def run
    latest_release = `wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE`
    if (`chromedriver --version` rescue '').include?(" #{latest_release} ")
      puts("The latest chromedriver release (#{latest_release}) is already installed.")
    else
      filename = OS.mac? ? 'chromedriver_mac64.zip' : 'chromedriver_linux64.zip'
      execute_system_command(<<~COMMAND)
        curl -o $(pwd)/tmp/chromedriver.zip
        https://chromedriver.storage.googleapis.com/#{latest_release}/#{filename}
      COMMAND
      execute_system_command('rm -f $HOME/bin/chromedriver')
      execute_system_command('unzip -d "$HOME/bin/" $(pwd)/tmp/chromedriver.zip')
    end

    # we print the chromedriver version, to make sure that it was installed successfully and so that
    # we can view it for debugging, but we don't check it against a specific value, because it is
    # indeterminate / constantly changing (since we always use the latest Chrome and `chromedriver`)
    execute_system_command('chromedriver --version')
  end
end
