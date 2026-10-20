class Test::Tasks::RunActiveRecordDoctor < Pallets::Task
  include Test::TaskHelpers

  def run
    execute_rake_task('active_record_doctor')
  end
end
