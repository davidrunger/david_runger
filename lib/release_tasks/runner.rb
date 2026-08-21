class ReleaseTasks::Runner
  def run_task(task_description)
    print("#{task_description}... ")
    start_time = Time.current
    yield
    puts("done. (Took #{(Time.current - start_time).round(2)} seconds.)")
  end

  def run_rake_task_with_retries(task_name, attempts: 10)
    rake_task = Rake::Task[task_name]

    (1..attempts).each do |attempt_number|
      Rails.logger.info("attempt ##{attempt_number}... ")
      rake_task.invoke
      break
    rescue => error
      pp(error)
      raise if attempt_number == attempts

      rake_task.reenable
      sleep(attempt_number)
    end
  end

  def with_modified_env(env_modifications)
    original_env_values = {}

    env_modifications.each do |env_var, new_value|
      original_env_values[env_var] = ENV.fetch(env_var, nil)
      ENV[env_var] = new_value # rubocop:disable Rails/EnvironmentVariableAccess
    end

    yield
  ensure
    original_env_values.each do |env_var, original_value|
      ENV[env_var] = original_value # rubocop:disable Rails/EnvironmentVariableAccess
    end
  end
end
