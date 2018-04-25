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
    run_logged_system_command('bin/rspec --format documentation')
  end

  desc 'Run JavaScript specs'
  task js: :environment do
    # boot test server first, so that it will definitely be launched by the time that we need it
    run_logged_system_command('ruby -run -ehttpd public -p8080 &> /dev/null &')

    # JavaScript setup
    run_logged_system_command('bin/setup-mocha-tests >/dev/null 2>&1')
    bin_webpack = Rails.root.join('bin', 'webpack')
    # run_logged_system_command("NODE_ENV=test #{dev_server} > personal/stdout 2> personal/stderr", background: true)
    run_logged_system_command("NODE_ENV=test #{bin_webpack} > /dev/null")

    # run tests
    run_logged_system_command("yarn run test#{ENV.key?('TRAVIS') ? '-no-sandbox' : ''}")
  end
end
