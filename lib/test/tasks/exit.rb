class Test::Tasks::Exit < Pallets::Task
  include Test::TaskHelpers
  prepend Memoization

  def run
    @overall_finish_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    post_ci_step_results
    print_individual_task_times
    print_overall_time_and_parallelism
    print_failed_commands
    print_exit_code_info
    exit(exit_code)
  end

  private

  def post_ci_step_results
    if ci_step_results_host.present?
      print("\nPosting CiStepResults ... ")

      begin
        response =
          Faraday.json_connection.post(
            "#{ci_step_results_host}/api/ci_step_results/bulk_creations",
            {
              auth_token: ENV.fetch('CI_STEP_RESULTS_AUTH_TOKEN'),
              ci_step_results: ci_step_results_data,
            },
          )

        puts("response:#{response.status}.")

        if (response.status / 100) > 2
          pp(response.body)
        end
      rescue => error
        puts('error. We have rescued it and will proceed.')
        pp(error)
      end
    else
      puts('CI_STEP_RESULTS_HOST is not present; not sending results.')
    end
  end

  def ci_step_results_data
    {
      'WallClockTime' => {
        run_time: overall_wall_clock_time,
        start_time: earliest_task_start_time,
        stop_time: latest_task_stop_time,
        exit_code:,
      },
      'CpuTime' => {
        run_time: total_task_time,
        start_time: earliest_task_start_time,
        stop_time: latest_task_stop_time,
        exit_code:,
      },
    }.
      merge(job_results).
      map do |task_name, result_hash|
        data_for_ci_step_result(task_name, result_hash)
      end
  end

  def data_for_ci_step_result(task_name, result_hash)
    {
      name: task_name.delete_prefix('Test::Tasks::'),
      seconds: result_hash[:run_time],
      started_at: result_hash[:start_time].utc.iso8601(6),
      stopped_at: result_hash[:stop_time].utc.iso8601(6),
      passed: result_hash[:exit_code] == 0,
      github_run_id: ENV.fetch('GITHUB_RUN_ID'),
      github_run_attempt: ENV.fetch('GITHUB_RUN_ATTEMPT'),
      branch: ENV.fetch('GITHUB_HEAD_REF', nil).presence || ENV.fetch('GITHUB_REF_NAME'),
      sha: ENV.fetch('GIT_REV'),
    }
  end

  memoize \
  def ci_step_results_host
    ENV.fetch('CI_STEP_RESULTS_HOST', nil)
  end

  def exit_code
    Test::Runner.exit_code
  end

  def print_exit_code_info
    puts("\n")
    puts("Exiting with code #{exit_code}")
  end

  def print_individual_task_times
    puts("\n")
    sorted_job_results.
      each do |task_name, result_hash|
        exit_code = result_hash[:exit_code]
        run_time = result_hash[:run_time]
        exit_message = "exited with #{exit_code}"
        exit_message_color = (exit_code == 0) ? :green : :red
        colorized_exit_message = AmazingPrint::Colors.public_send(exit_message_color, exit_message)
        puts(
          "#{rjusted_short_name(task_name)} : " \
          "#{colorized_exit_message} " \
          "(took #{AmazingPrint::Colors.yellow(('%0.3f' % run_time)[0, 6].rjust(6, ' '))} seconds)",
        )
      end
  end

  def print_overall_time_and_parallelism
    puts("\n")
    puts(<<~LOG.squish)
      Wall clock elapsed time: #{AmazingPrint::Colors.yellow(overall_wall_clock_time.round(3).to_s)}
    LOG
    puts("Total task time: #{AmazingPrint::Colors.yellow(total_task_time.round(3).to_s)}")
    puts(<<~LOG.squish)
      Parallelism:
      #{AmazingPrint::Colors.yellow(total_task_time.fdiv(overall_wall_clock_time).round(3).to_s)}
    LOG
  end

  def print_failed_commands
    printed_header = false
    sorted_job_results.each do |task_name, result_hash|
      failed_commands = Array(result_hash[:failed_commands])
      next if failed_commands.empty?

      puts("\n=== #{AmazingPrint::Colors.red('Failed commands')} ===") if !printed_header
      printed_header = true

      failed_commands.each do |failed_command|
        puts(
          "#{rjusted_short_name(task_name, tasks_with_failed_commands)} : " \
          "#{AmazingPrint::Colors.red(failed_command)}",
        )
      end
    end
  end

  def tasks_with_failed_commands
    job_results.filter_map do |task_name, result_hash|
      task_name if result_hash.key?(:failed_commands)
    end
  end

  def overall_wall_clock_time
    @overall_finish_time - Test::Runner.start_time
  end

  memoize \
  def total_task_time
    job_results.sum { |_key, value| value[:run_time] }
  end

  memoize \
  def earliest_task_start_time
    job_results.values.map { it[:start_time] }.min
  end

  memoize \
  def latest_task_stop_time
    job_results.values.map { it[:stop_time] }.max
  end

  def short_job_names(task_set)
    task_set.map { it.sub('Test::Tasks::', '') }
  end

  def job_results
    Test::Middleware::TaskResultTrackingMiddleware.job_results
  end

  def sorted_job_results
    job_results.sort_by do |_task_name, result_hash|
      [result_hash.fetch(:exit_code), result_hash.fetch(:run_time)]
    end
  end

  def max_job_name_length(task_set)
    short_job_names(task_set).map(&:size).max
  end

  def rjusted_short_name(task_name, task_set = job_results.keys)
    task_name.sub('Test::Tasks::', '').rjust(max_job_name_length(task_set))
  end
end
