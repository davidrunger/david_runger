class Test::Tasks::RunTsd < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND.squish)
      ./node_modules/.bin/tsd
      --files app/javascript/types/index.test-examples.ts
      --typings app/javascript/types/index.ts
    COMMAND
  end
end
