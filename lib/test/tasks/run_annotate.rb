# frozen_string_literal: true

class Test::Tasks::RunAnnotate < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      bin/annotate --models --show-indexes --sort --exclude fixtures,tests && git diff --exit-code
    COMMAND
  end
end
