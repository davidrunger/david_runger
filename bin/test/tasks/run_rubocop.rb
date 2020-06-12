# frozen_string_literal: true

class Test::Tasks::RunRubocop < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      bin/rubocop $(git ls-tree -r HEAD --name-only) --force-exclusion --format clang
    COMMAND
  end
end
