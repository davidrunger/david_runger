def run_logged_system_command(command, background: false)
  if background
    puts "Backgrounding command '#{command}' ..."
    system("#{command} &")
    true
  else
    print "Running system command '#{command}' ... "

    if system(command)
      true
    else
      abort("System command `#{command}` exited with a non-zero status.")
    end
  end
end

def webpack_dev_server_running?
  Net::HTTP.get(URI('http://localhost:8080/packs-test/manifest.json'))
  Net::HTTP.get(URI('http://localhost:8080/packs-test/mocha.js'))
  Net::HTTP.get(URI('http://localhost:8080/packs-test/mocha.css'))
  Net::HTTP.get(URI('http://localhost:8080/packs-test/spec_index.js'))
rescue
  false
else
  puts 'webpack-dev-server is ready!'
  true
end

namespace :spec do
  desc 'Run Ruby specs'
  task :rb do
    run_logged_system_command('bin/rspec --format documentation')
  end

  desc 'Run JavaScript specs'
  task js: :environment do
    run_logged_system_command('bin/setup-mocha-tests >/dev/null 2>&1')
    print "\n"
    dev_server = Rails.root.join('bin', 'webpack-dev-server')
    run_logged_system_command("NODE_ENV=test #{dev_server} >/dev/null 2>&1", background: true)
    print 'Waiting for webpack-dev-server to boot up '
    120.times do # wait up to 2 minutes for webpack-dev-server to start, checking each second
      sleep(1)
      if webpack_dev_server_running?
        break
      else
        print '.'
      end
    end

    run_logged_system_command('yarn run test')
  end
end
