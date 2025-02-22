class Test::Tasks::FeatureTestsCanStart < Pallets::Task
  include Test::TaskHelpers

  def run
    puts("#{AmazingPrint::Colors.yellow('Sleeping for 0.1 seconds')}...")

    sleep(0.1)

    record_success_and_log_message('Done sleeping for 0.1 seconds.')
  end
end
