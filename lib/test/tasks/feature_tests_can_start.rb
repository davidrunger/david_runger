class Test::Tasks::FeatureTestsCanStart < Pallets::Task
  include Test::TaskHelpers

  def run
    run_ruby_code(task_description: 'Sleeping for 0.1 seconds') do
      sleep(0.1)
    end
  end
end
