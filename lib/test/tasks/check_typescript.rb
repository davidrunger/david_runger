# frozen_string_literal: true

class Test::Tasks::CheckTypescript < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('./node_modules/.bin/vue-tsc --noEmit')
  end
end
