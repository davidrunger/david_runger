# frozen_string_literal: true

class Test::Tasks::CompileJavaScript < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('rm -rf public/vite/ public/vite-admin/')
    execute_rake_task('build_js_routes')
    execute_system_command(
      'bin/vite build --force',
      {
        'NODE_ENV' => 'production',
      },
    )
    execute_system_command(
      'bin/vite build --force',
      {
        'NODE_ENV' => 'production',
        'VITE_RUBY_ENTRYPOINTS_DIR' => 'admin_packs',
        'VITE_RUBY_PUBLIC_OUTPUT_DIR' => 'vite-admin',
      },
    )
    if ENV.fetch('CI', nil) == 'true' && ENV.fetch('GITHUB_REF_NAME') == 'master'
      execute_rake_task('assets:upload_vite_assets')
    end
  end
end
