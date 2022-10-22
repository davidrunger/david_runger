# frozen_string_literal: true

require 'open3'

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
      record_failed_command(command)
      puts(<<~LOG.squish.red)
        '#{command.red}' with ENV vars #{env_vars.to_s.red} failed
        (exited with #{exit_code}, took #{time.round(3)}).
      LOG
    end
  end

  def execute_rspec_command(command, env_vars = {})
    command = command.squish
    puts("Running system command '#{command.yellow}' with ENV vars #{env_vars.to_s.yellow} ...")
    stdout, _stderr, status = nil, nil, nil # rubocop:disable Style/ParallelAssignment
    time =
      Benchmark.measure do
        stdout, _stderr, status = Open3.capture3(env_vars, command)
      end.real
    puts(stdout)
    exit_code = status.success? ? 0 : 1
    update_job_result_exit_code(exit_code)
    if exit_code == 0
      puts(<<~LOG.squish)
        '#{command.green}' with ENV vars #{env_vars.to_s.green} succeeded
        (exited with #{exit_code}, took #{time.round(3)}).
      LOG
    else
      Test::Runner.exit_code = exit_code if Test::Runner.exit_code == 0
      record_failed_tests(stdout)
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
