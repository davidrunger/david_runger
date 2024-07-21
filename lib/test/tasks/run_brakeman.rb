class Test::Tasks::RunBrakeman < Pallets::Task
  include Test::TaskHelpers

  def run
    # skip `application_worker.rb` because it has `...`, which the brakeman parser cannot understand
    execute_system_command(<<~COMMAND.squish, log_stdout_only_on_failure: true)
      bin/brakeman
        --quiet
        --no-pager
        --skip-files app/workers/application_worker.rb
    COMMAND
  end
end
