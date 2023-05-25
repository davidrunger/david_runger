# frozen_string_literal: true

require 'open3'

module Test::TaskHelpers
  def execute_system_command(command, env_vars = {})
    command = command.squish
    puts(<<~LOG.squish)
      Running system command '#{AmazingPrint::Colors.yellow(command)}'
      with ENV vars #{AmazingPrint::Colors.yellow(env_vars.to_s)} ...
    LOG
    time = Benchmark.measure { system(env_vars, command) }.real
    exit_code = $CHILD_STATUS.exitstatus
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
    puts(<<~LOG)
      Running rake task '#{AmazingPrint::Colors.yellow(task_name)}'
      with args #{AmazingPrint::Colors.yellow(args.inspect)} ...
    LOG
    time = nil
    begin
      time = Benchmark.measure { Rake::Task[task_name].invoke(*args) }.real
    rescue SystemExit => error
      update_job_result_exit_code(1)
      puts(AmazingPrint::Colors.red(
        "'#{task_name}' failed ('exited with 1', raised #{error.inspect}).",
      ))
      raise # this will exit the program if it's a `SystemExit` exception
    rescue => error
      args_string = "[#{args.map(&:to_s).join(',')}]"
      record_failed_command("bin/rails #{task_name}#{args_string if !args.empty?}")
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
    unless preexisting_exit_code.present? && (preexisting_exit_code > exit_code)
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
      match(%r{\nFailed examples:\n\n(.*)\n\nRandomized with seed}m).[](1).
      split("\n").
      each do |failed_test|
        job_result_hash[:failed_commands] << failed_test.sub(%r{\A\e\[31mrspec ./}, '')
      end
  end

  def job_result_hash
    Test::Middleware::TaskResultTrackingMiddleware.job_results[self.class.name]
  end
end
