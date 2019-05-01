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

  desc 'Set up JavaScript specs'
  task :setup_js do
    # boot test server
    run_logged_system_command('ruby -run -ehttpd public -p8080 &> /dev/null &')

    # setup tests
    run_logged_system_command('bin/setup-mocha-tests >/dev/null 2>&1')

    # compile
    run_logged_system_command("NODE_ENV=test #{Rails.root.join('bin', 'webpack')} > /dev/null")
  end

  desc 'Run JavaScript tests (after setting up already)'
  task :run_js do
    run_logged_system_command('yarn run test')
  end

  desc 'Run JavaScript specs'
  task js: :environment do
    Rake::Task['spec:setup_js'].invoke
    Rake::Task['spec:run_js'].invoke
  end
end
