# frozen_string_literal: true

class Test::Tasks::Exit < Pallets::Task
  def run
    puts("Exiting with code #{Test::Runner.exit_code}")
    exit(Test::Runner.exit_code)
  end
end
