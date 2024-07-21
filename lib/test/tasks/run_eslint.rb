class Test::Tasks::RunEslint < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command(<<~COMMAND)
      ./node_modules/.bin/eslint --max-warnings 0 --ext .js,.ts,.vue app/javascript/
    COMMAND
  end
end
