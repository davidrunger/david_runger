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
      Rake::Task['assets:copy_webpacker_settings'].invoke(
        'production',
        'test',
        'cache_manifest compile extract_css source_path',
      )
      run_logged_system_command('RAILS_ENV=test NODE_ENV=test bin/webpack --silent')
      run_logged_system_command(<<~COMMAND.squish)
        #{'./node_modules/.bin/percy exec -- ' if ENV['PERCY_TOKEN'].present?}
        bin/rspec --format documentation
      COMMAND
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
    bin_webpack_path = Rails.root.join('bin/webpack')
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
      "ps -ax | egrep 'ruby.*httpd' | egrep -v grep | awk '{print $1}' | xargs kill",
    )
  end

  desc 'Run JavaScript specs'
  task js: :environment do
    Rake::Task['spec:setup_js'].invoke
    Rake::Task['spec:poll_js'].invoke
    Rake::Task['spec:run_js'].invoke
  end
end
