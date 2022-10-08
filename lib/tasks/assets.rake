# frozen_string_literal: true

namespace :assets do
  def run_logged_system_command(command, env_vars = {})
    puts "Running system command '#{command.blue}' with ENV vars #{env_vars}..."
    if system(env_vars, command)
      puts '... success.'
    else
      puts '... failed.'
    end
  end

  def run_logged_rake_task(rake_task_name)
    puts "Running rake task '#{rake_task_name.blue}' ..."
    Rake::Task[rake_task_name].invoke
    puts '... success.'
  end

  desc 'Boot a server in development that serves assets in a production-like manner'
  task :production_asset_server do
    run_logged_system_command('rm -rf node_modules/')
    run_logged_system_command('rm -rf public/assets/ public/vite/ public/vite-admin/')
    run_logged_system_command('rm -f app/javascript/rails_assets/routes.js')
    run_logged_system_command('yarn install', { 'NODE_ENV' => 'production' })
    run_logged_rake_task('assets:precompile')
    run_logged_system_command(
      'bin/rails server',
      {
        'DISABLE_SPRING' => '1',
        'PRODUCTION_ASSET_CONFIG' => '1',
        'VITE_RUBY_AUTO_BUILD' => 'false',
      },
    )
  end
end

Rake::Task['assets:precompile'].enhance(%w[build_js_routes]) do
  system('bin/vite build --force', exception: true)
  system(
    {
      'VITE_RUBY_ENTRYPOINTS_DIR' => 'admin_packs',
      'VITE_RUBY_PUBLIC_OUTPUT_DIR' => 'vite-admin',
    },
    'bin/vite build --force',
    exception: true,
  )
end

if Rails.env.production?
  Rake::Task['assets:clean'].enhance do
    FileUtils.remove_dir('node_modules', true)
  end
end
