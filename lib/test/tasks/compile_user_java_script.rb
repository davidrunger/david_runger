class Test::Tasks::CompileUserJavaScript < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('rm -rf public/vite/')

    execute_system_command(
      'bin/vite build --force',
      {
        'NODE_ENV' => 'production',
      },
    )
  end
end
