# frozen_string_literal: true

class Test::Tasks::Exit < Pallets::Task
  include Test::TaskHelpers

  def run
    puts("Exiting with code #{Test::Runner.exit_code}")
    exit(Test::Runner.exit_code)
  end
end
