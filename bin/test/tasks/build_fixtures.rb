# frozen_string_literal: true

class Test::Tasks::BuildFixtures < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rake_task('spec:fixture_builder:rebuild')
  end
end
