# frozen_string_literal: true

class Test::Tasks::CompileJavaScript < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('rm -rf public/vite/')
    execute_rake_task('build_js_routes')
    execute_system_command('bin/vite build --force')
    execute_system_command(
      'VITE_RUBY_ENTRYPOINTS_DIR=admin_packs VITE_RUBY_PUBLIC_OUTPUT_DIR=vite-admin ' \
      'bin/vite build --force',
    )
  end
end
