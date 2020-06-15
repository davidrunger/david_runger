# frozen_string_literal: true

module Test::TaskHelpers
  def execute_system_command(command)
    command = command.squish
    puts("Running system command '#{command}' ...")
    time = Benchmark.measure { system(command) }.real
    exit_code = $CHILD_STATUS.exitstatus
    update_job_result_exit_code(exit_code)
    if exit_code == 0
      puts("'#{command}' succeeded (exited with #{exit_code}, took #{time.round(3)}).".green)
    else
      Test::Runner.exit_code = exit_code if Test::Runner.exit_code == 0
      puts("'#{command}' failed (exited with #{exit_code}, took #{time.round(3)}).".red)
    end
  end

  def execute_rake_task(task_name, *args)
    puts("Running rake task '#{task_name}' with args #{args.inspect} ...")
    time = nil
    begin
      time = Benchmark.measure { Rake::Task[task_name].invoke(*args) }.real
    rescue SystemExit => error
      update_job_result_exit_code(1)
      puts("'#{task_name}' failed ('exited with 1', raised #{error.inspect}).".red)
      raise # this will exit the program if it's a `SystemExit` exception
    rescue => error
      update_job_result_exit_code(1)
      puts("'#{task_name}' failed ('exited with 1', raised #{error.inspect}).".red)
      Test::Runner.exit_code = 1 if Test::Runner.exit_code == 0
    else
      update_job_result_exit_code(0)
      puts("'#{task_name}' succeeded (took #{time.round(3)}).".green)
    end
  end

  private

  def update_job_result_exit_code(exit_code)
    preexisting_exit_code = job_result_hash[:exit_code]
    # a previous command in the same task might've exited with a non-zero status; don't overwrite it
    unless preexisting_exit_code.present? && (preexisting_exit_code > exit_code)
      job_result_hash[:exit_code] = exit_code
    end
  end

  def job_result_hash
    Test::Middleware::TaskResultTrackingMiddleware.job_results[self.class.name]
  end
end
