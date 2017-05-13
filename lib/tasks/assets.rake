namespace :assets do
  def run_logged_system_command(command)
    puts "Running system command '#{command}' ..."
    if system(command)
      puts '... success.'
    else
      puts '... failed.'
    end
  end

  desc 'clean yarn cache'
  task :clean_yarn_cache do
    run_logged_system_command('yarn cache clean')
  end

  desc 'delete the node_modules directory'
  task :rmrf_node_module do
    run_logged_system_command('rm -rf node_modules')
  end
end

Rake::Task['assets:precompile'].enhance(%w[
  assets:clean_yarn_cache
  assets:rmrf_node_module
])
