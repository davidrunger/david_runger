class Test::Tasks::CompileUserJavaScript < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('rm -rf public/vite/')

    execute_system_command(
      './node_modules/.bin/vite build',
      {
        'NODE_ENV' => 'production',
      },
    )
  end
end
