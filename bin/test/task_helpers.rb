# frozen_string_literal: true

module Test::TaskHelpers
  def execute_system_command(command)
    command = command.squish
    puts("Running system command '#{command}' ...")
    time = Benchmark.measure { system(command) }.real
    exit_code = $CHILD_STATUS.exitstatus
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
      puts("'#{task_name}' failed ('exited with 1', raised #{error.inspect}).".red)
      raise # this will exit the program if it's a `SystemExit` exception
    rescue => error
      puts("'#{task_name}' failed ('exited with 1', raised #{error.inspect}).".red)
      Test::Runner.exit_code = 1 if Test::Runner.exit_code == 0
    else
      puts("'#{task_name}' succeeded (took #{time.round(3)}).".green)
    end
  end
end
