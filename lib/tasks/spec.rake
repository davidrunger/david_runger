# frozen_string_literal: true

def run_logged_system_command(command)
  puts "Running system command '#{command}' ... "

  if system(command)
    true
  else
    abort("System command `#{command}` exited with a non-zero status.")
  end
end

namespace :spec do
  desc 'Run Ruby specs'
  task :rb do
    begin
      Rake::Task['spec:copy_production_webpacker_settings_to_test'].
        invoke('cache_manifest compile extract_css source_path')
      run_logged_system_command('RAILS_ENV=test NODE_ENV=test bin/webpack --silent')
      run_logged_system_command('bin/rspec --format documentation')
    ensure
      run_logged_system_command('git checkout config/webpacker.yml')
    end
  end

  desc 'Set up JavaScript specs'
  task :setup_js do
    # boot test server
    run_logged_system_command('ruby -run -ehttpd public -p8080 > /dev/null 2>&1 &')

    # setup tests
    run_logged_system_command('bin/setup-mocha-tests >/dev/null 2>&1')

    # compile
    bin_webpack_path = Rails.root.join('bin', 'webpack')
    run_logged_system_command("NODE_ENV=test #{bin_webpack_path} > /dev/null")
  end

  desc 'Poll until JavaScript test server bootup is confirmed'
  task :poll_js do
    max_polls = 401
    sleep_interval = 0.2
    poll_target = 'http://localhost:8080/packs-test/mocha_runner.html'

    puts "Polling for #{poll_target}"
    (1..max_polls).each do |poll_attempt|
      response_code = HTTParty.get(poll_target).code rescue nil
      if response_code == 200
        puts "#{poll_target} returned 200"
        break
      end

      if poll_attempt == max_polls
        seconds_of_polling = (max_polls - 1) * sleep_interval
        abort(<<~ABORT_MSG.squish)
          Didn't get a 200 response
          after #{Integer(seconds_of_polling)} seconds
          of polling #{poll_target}
        ABORT_MSG
      else
        sleep(sleep_interval)
      end
    end
  end

  desc 'Run JavaScript tests (after setting up already)'
  task :run_js do
    # run the tests
    run_logged_system_command('yarn run test')

    # kill JS unit test server (if running)
    run_logged_system_command(
      "ps -ax | egrep 'ruby.*httpd' | egrep -v egrep | awk '{print $1}' | xargs kill",
    )
  end

  desc 'Run JavaScript specs'
  task js: :environment do
    Rake::Task['spec:setup_js'].invoke
    Rake::Task['spec:poll_js'].invoke
    Rake::Task['spec:run_js'].invoke
  end

  desc <<~DESCRIPTION
    Copy specified production webpacker configuration settings to the test webpacker settings
    Example:
    $ bin/rails spec:copy_production_webpacker_settings_to_test["compile extract_css source_path"]
  DESCRIPTION
  task :copy_production_webpacker_settings_to_test, [:settings_to_copy] do |_task, args|
    webpacker_config_path = 'config/webpacker.yml'
    # rubocop:disable Security/YAMLLoad (this is trusted YAML; we don't need to load it "safely")
    webpacker_config = YAML.load(File.read(webpacker_config_path))
    # rubocop:enable Security/YAMLLoad
    production_config = webpacker_config['production']
    settings_to_copy = args[:settings_to_copy].split(/\s+/)
    File.write(
      webpacker_config_path,
      YAML.dump(webpacker_config.deep_merge('test' => production_config.slice(*settings_to_copy))),
    )
  end
end
