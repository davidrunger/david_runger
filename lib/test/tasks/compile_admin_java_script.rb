class Test::Tasks::CompileAdminJavaScript < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('rm -rf public/vite-admin/')

    execute_system_command(
      './node_modules/.bin/vite build 2> /dev/null',
      {
        'CI' => 'true', # This makes Vite not output info about all file sizes.
        'NODE_ENV' => 'production',
        'VITE_RUBY_ENTRYPOINTS_DIR' => 'admin_entrypoints',
        'VITE_RUBY_PUBLIC_OUTPUT_DIR' => 'vite-admin',
      },
    )
  end
end
