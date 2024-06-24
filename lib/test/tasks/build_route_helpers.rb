# frozen_string_literal: true

class Test::Tasks::BuildRouteHelpers < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rake_task('build_js_routes')
  end
end
