require 'open3'

module Test::TaskHelpers
  private

  def execute_system_command(command, env_vars = {}, log_stdout_only_on_failure: false)
    command = command.squish
    puts(<<~LOG.squish)
      Running system command '#{AmazingPrint::Colors.yellow(command)}'
      with ENV vars #{AmazingPrint::Colors.yellow(env_vars.to_s)} ...
    LOG
    stdout, status = nil, nil # rubocop:disable Style/ParallelAssignment
    time =
      Benchmark.measure do
        stdout, status = Open3.capture2(env_vars, command)
      end.real
    if !status.success? || !log_stdout_only_on_failure
      puts(stdout)
    end
    exit_code = status.success? ? 0 : 1
    update_job_result_exit_code(exit_code)
    if exit_code == 0
      puts(<<~LOG.squish)
        '#{AmazingPrint::Colors.green(command)}' with ENV vars #{AmazingPrint::Colors.green(env_vars.to_s)} succeeded
        (exited with #{exit_code}, took #{time.round(3)}).
      LOG
    else
      Test::Runner.exit_code = exit_code if Test::Runner.exit_code == 0
      record_failed_command(command)
      puts(AmazingPrint::Colors.red(<<~LOG.squish))
        '#{AmazingPrint::Colors.red(command)}' with ENV vars
        #{AmazingPrint::Colors.red(env_vars.to_s)} failed
        (exited with #{exit_code}, took #{time.round(3)}).
      LOG
    end

    status.success?
  end

  def execute_rspec_command(command, env_vars = {})
    command = command.squish
    puts(<<~LOG.squish)
      Running system command '#{AmazingPrint::Colors.yellow(command)}'
      with ENV vars #{AmazingPrint::Colors.yellow(env_vars.to_s)} ...
    LOG
    stdout, status = nil, nil # rubocop:disable Style/ParallelAssignment
    time =
      Benchmark.measure do
        stdout, status = Open3.capture2(env_vars, command)
      end.real
    puts(stdout)
    exit_code = status.success? ? 0 : 1
    update_job_result_exit_code(exit_code)
    if exit_code == 0
      puts(<<~LOG.squish)
        '#{AmazingPrint::Colors.green(command)}' with ENV vars #{AmazingPrint::Colors.green(env_vars.to_s)} succeeded
        (exited with #{exit_code}, took #{time.round(3)}).
      LOG
    else
      Test::Runner.exit_code = exit_code if Test::Runner.exit_code == 0
      record_failed_tests(stdout)
      puts(AmazingPrint::Colors.red(<<~LOG.squish))
        '#{AmazingPrint::Colors.red(command)}' with ENV vars #{AmazingPrint::Colors.red(env_vars.to_s)} failed
        (exited with #{exit_code}, took #{time.round(3)}).
      LOG
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def execute_rake_task(task_name, *args, log_stdout_only_on_failure: false)
    puts(<<~LOG.squish)
      Running rake task '#{AmazingPrint::Colors.yellow(task_name)}'
      with args #{AmazingPrint::Colors.yellow(args.inspect)} ...
    LOG

    time = nil
    captured_stdout = nil
    exception = nil

    begin
      time =
        Benchmark.measure do
          exception, captured_stdout =
            capturing_stdout_and_all_exceptions do
              Rake::Task[task_name].invoke(*args)
            end
        end.real

      if exception
        raise(exception)
      end
    rescue => error
      exception = error
    ensure
      if captured_stdout.present? && (!log_stdout_only_on_failure || exception.present?)
        puts(captured_stdout)
      end

      if exception.present?
        update_job_result_exit_code(1)

        puts(exception.backtrace)

        args_string = "[#{args.map(&:to_s).join(',')}]"
        record_failed_command("bin/rails #{task_name}#{args_string if !args.empty?}")
        record_failure_and_log_message(
          "'#{task_name}' failed ('exited with 1', raised #{error.inspect}).",
        )
      else
        record_success_and_log_message("'#{task_name}' succeeded (took #{time.round(3)}).")
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  def capturing_stdout_and_all_exceptions
    original_stdout = $stdout
    captured = StringIO.new
    $stdout = captured
    exception = nil

    begin
      yield
    rescue Exception => error # rubocop:disable Lint/RescueException
      exception = error
    end

    [exception, captured.string]
  ensure
    $stdout = original_stdout
  end

  def record_success_and_log_message(message)
    update_job_result_exit_code(0)
    puts(AmazingPrint::Colors.green(message))
  end

  def record_failure_and_log_message(message)
    update_job_result_exit_code(1)
    puts(AmazingPrint::Colors.red(message))
    Test::Runner.exit_code = 1 if Test::Runner.exit_code == 0
  end

  def update_job_result_exit_code(exit_code)
    preexisting_exit_code = job_result_hash[:exit_code]
    # a previous command in the same task might've exited with a non-zero status; don't overwrite it
    if preexisting_exit_code.blank? || (preexisting_exit_code < exit_code)
      job_result_hash[:exit_code] = exit_code
    end
  end

  def record_failed_command(command)
    job_result_hash[:failed_commands] ||= []
    job_result_hash[:failed_commands] << command
  end

  def record_failed_tests(stdout)
    job_result_hash[:failed_commands] ||= []
    stdout.
      match(%r{\nFailed examples:\n{1,2}(.*)\n{1,2}(Randomized|Coverage)}m).[](1).
      scan(%r{^\S{0,10}rspec \./.+$}).
      each do |failed_test|
        job_result_hash[:failed_commands] << failed_test.sub(%r{\A\e\[31mrspec ./}, '')
      end
  end

  def job_result_hash
    job_results[self.class.name]
  end

  def job_results
    if $PROGRAM_NAME.end_with?('bin/run-test-steps')
      # This allows bin/run-test-step to work without the pallets middleware loaded.
      Hash.new { |hash, key| hash[key] = Hash.new { |h, k| h[k] = [] } }
    else
      Test::Middleware::TaskResultTrackingMiddleware.job_results
    end
  end
end
