# frozen_string_literal: true

class Test::Tasks::RunStylelint < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_system_command('./node_modules/.bin/stylelint app/**/*.{css,scss,vue} --max-warnings 0')
  end
end
