class Test::Tasks::CompileUserJavaScript < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('rm -rf public/vite/')

    execute_system_command(
      './node_modules/.bin/vite build',
      {
        'CI' => 'true', # This makes Vite not output info about all file sizes.
        'NODE_ENV' => 'production',
      },
    )
  end
end
