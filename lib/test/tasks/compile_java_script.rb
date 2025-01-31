class Test::Tasks::CompileJavaScript < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('rm -rf public/vite/ public/vite-admin/')

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
        'VITE_RUBY_ENTRYPOINTS_DIR' => 'admin_entrypoints',
        'VITE_RUBY_PUBLIC_OUTPUT_DIR' => 'vite-admin',
      },
    )

    if ENV.fetch('CI', nil) == 'true' && ENV.fetch('GITHUB_REF_NAME') == 'main'
      execute_rake_task(
        'assets:upload_vite_assets',
        log_stdout_only_on_failure: true,
      )
    end
  end
end
