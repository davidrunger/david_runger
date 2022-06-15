# frozen_string_literal: true

namespace :assets do
  def run_logged_system_command(command)
    puts "Running system command '#{command}' ..."
    if system(command)
      puts '... success.'
    else
      puts '... failed.'
    end
  end

  desc 'Boot a server in development that serves assets in a production-like manner'
  task :production_asset_server do
    run_logged_system_command('rm -rf node_modules/')
    run_logged_system_command('rm -rf public/vite/ public/vite-dev/')
    run_logged_system_command('rm -f app/javascript/rails_assets/routes.js')
    run_logged_system_command('DISABLE_SPRING=1 bin/rails build_js_routes')
    run_logged_system_command('NODE_ENV=production yarn install')
    run_logged_system_command('NODE_ENV=production bin/vite build --force')
    run_logged_system_command('PRODUCTION_ASSET_CONFIG=1 DISABLE_SPRING=1 bin/rails server')
  end
end

if Rails.env.production?
  Rake::Task['assets:precompile'].enhance(%w[build_js_routes]) do
    system(
      {
        'VITE_RUBY_ENTRYPOINTS_DIR' => 'admin_packs',
        'VITE_RUBY_PUBLIC_OUTPUT_DIR' => 'vite-admin',
      },
      'bin/vite build --force',
    )
  end

  Rake::Task['assets:clean'].enhance do
    FileUtils.remove_dir('node_modules', true)
  end
end
