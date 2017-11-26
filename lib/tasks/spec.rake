def run_logged_system_command(command, background: false)
  if background
    puts "Backgrounding command '#{command}' ..."
    system("#{command} &")
    true
  else
    puts "Running system command '#{command}' ..."
    if system(command)
      puts '... success.'
      true
    else
      puts '... failed.'
      false
    end
  end
end

def webpack_dev_server_running?
  Net::HTTP.get(URI('http://localhost:8080/packs-test/manifest.json'))
  Net::HTTP.get(URI('http://localhost:8080/packs-test/mocha.js'))
  Net::HTTP.get(URI('http://localhost:8080/packs-test/mocha.css'))
  Net::HTTP.get(URI('http://localhost:8080/packs-test/spec_index.js'))
rescue
  puts 'webpack-dev-server is not ready yet ...'
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
    run_logged_system_command('node --version')
    run_logged_system_command('yarn --version')
    run_logged_system_command('webpack --version')
    run_logged_system_command('bin/setup-mocha-tests')
    run_dev_server = Rails.root.join('bin', 'webpack-dev-server')
    run_logged_system_command("NODE_ENV=test #{run_dev_server}", background: true)
    puts 'Waiting for webpack-dev-server to boot up ...'
    120.times do # wait up to 2 minutes for webpack-dev-server to start, checking each second
      sleep(1)
      break if webpack_dev_server_running?
    end

    exit(1) unless run_logged_system_command('yarn run test')
  end
end
