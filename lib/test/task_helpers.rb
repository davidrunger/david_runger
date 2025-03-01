require 'open3'

module Test::TaskHelpers
  prepend Memoization

  private

  def logger
    ActiveSupport::Logger.new($stdout).tap do |logger|
      logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end.then do |logger|
      ActiveSupport::TaggedLogging.new(logger)
    end.
      tagged(self.class.name.delete_prefix('Test::Tasks::'))
  end

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

  def execute_detached_system_command(command)
    puts(<<~LOG.squish)
      Running system command '#{AmazingPrint::Colors.yellow(command)}'
      and detaching the process ...
    LOG

    pid = Process.spawn(command, pgroup: true)
    Process.detach(pid)

    update_job_result_exit_code(0)

    puts(<<~LOG.squish)
      '#{AmazingPrint::Colors.green(command)}' was spawned and detached.
    LOG
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

  def execute_rake_task(task_name, *args)
    puts(<<~LOG.squish)
      Running rake task '#{AmazingPrint::Colors.yellow(task_name)}'
      with args #{AmazingPrint::Colors.yellow(args.inspect)} ...
    LOG

    time = nil
    exception = nil

    begin
      time =
        Benchmark.measure do
          Rake::Task[task_name].invoke(*args)
        end.real
    rescue => error
      exception = error
    ensure
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
