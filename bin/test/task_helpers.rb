# frozen_string_literal: true

module Test::TaskHelpers
  def execute_system_command(command, env_vars = {})
    command = command.squish
    puts("Running system command '#{command.yellow}' with ENV vars #{env_vars.to_s.yellow} ...")
    time = Benchmark.measure { system(env_vars, command) }.real
    exit_code = $CHILD_STATUS.exitstatus
    update_job_result_exit_code(exit_code)
    if exit_code == 0
      puts(<<~LOG.squish)
        '#{command.green}' with ENV vars #{env_vars.to_s.green} succeeded
        (exited with #{exit_code}, took #{time.round(3)}).
      LOG
    else
      Test::Runner.exit_code = exit_code if Test::Runner.exit_code == 0
      puts(<<~LOG.squish.red)
        '#{command.red}' with ENV vars #{env_vars.to_s.red} failed
        (exited with #{exit_code}, took #{time.round(3)}).
      LOG
    end
  end

  def execute_rake_task(task_name, *args)
    puts("Running rake task '#{task_name.yellow}' with args #{args.inspect.yellow} ...")
    time = nil
    begin
      time = Benchmark.measure { Rake::Task[task_name].invoke(*args) }.real
    rescue SystemExit => error
      update_job_result_exit_code(1)
      puts("'#{task_name}' failed ('exited with 1', raised #{error.inspect}).".red)
      raise # this will exit the program if it's a `SystemExit` exception
    rescue => error
      record_failure_and_log_message(
        "'#{task_name}' failed ('exited with 1', raised #{error.inspect}).",
      )
    else
      record_success_and_log_message("'#{task_name}' succeeded (took #{time.round(3)}).")
    end
  end

  private

  def record_success_and_log_message(message)
    update_job_result_exit_code(0)
    puts(message.green)
  end

  def record_failure_and_log_message(message)
    update_job_result_exit_code(1)
    puts(message.red)
    Test::Runner.exit_code = 1 if Test::Runner.exit_code == 0
  end

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
