# frozen_string_literal: true

class Test::Tasks::Exit < Pallets::Task
  include Test::TaskHelpers

  def run
    @overall_finish_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    post_runtime_to_log
    print_individual_task_times
    print_overall_time_and_parallelism
    print_exit_code_info
    exit(exit_code)
  end

  private

  def exit_code
    Test::Runner.exit_code
  end

  def print_exit_code_info
    puts("\n")
    puts("Exiting with code #{exit_code}")
  end

  def print_individual_task_times
    puts("\n")
    max_job_name_length = short_job_names.map(&:size).max
    Test::Middleware::TaskResultTrackingMiddleware.job_results.
      sort_by { |_task_name, result_hash| [result_hash[:exit_code], result_hash[:run_time]] }.
      each do |task_name, result_hash|
        exit_code = result_hash[:exit_code]
        run_time = result_hash[:run_time]
        exit_message = "exited with #{exit_code}"
        exit_message_color = (exit_code == 0) ? :green : :red
        colorized_exit_message = exit_message.public_send(exit_message_color)
        puts(
          "#{task_name.sub('Test::Tasks::', '').rjust(max_job_name_length)} : "\
          "#{colorized_exit_message} "\
          "(took #{run_time.round(3).to_s.yellow} seconds)",
        )
      end
  end

  def print_overall_time_and_parallelism
    puts("\n")
    puts("Wall clock elapsed time: #{overall_wall_clock_time.round(3).to_s.yellow}")
    total_task_time =
      Test::Middleware::TaskResultTrackingMiddleware.job_results.map { _2[:run_time] }.inject(:+)
    puts("Total task time: #{total_task_time.round(3).to_s.yellow}")
    puts("Parallelism: #{total_task_time.fdiv(overall_wall_clock_time).round(3).to_s.yellow}")
  end

  def post_runtime_to_log
    print("\nPosting data to log... ")
    response =
      HTTParty.post(
        ENV['BUILD_TIME_LOG_URL'],
        body: {
          auth_token: ENV['BUILD_TIME_LOG_AUTH_TOKEN'],
          log_entry: {
            log_id: ENV['BUILD_TIME_LOG_ID'],
            data: overall_wall_clock_time.round(1),
            note: log_note,
          },
        },
      )
    code = response.code
    puts("Response code: #{(code == 201) ? code.to_s.green : code.to_s.red}")
  end

  def log_note
    "exit_code=#{exit_code} tasks=#{short_job_names.sort.join(',')} branch=#{ENV['TRAVIS_BRANCH']}"
  end

  def overall_wall_clock_time
    @overall_finish_time - Test::Runner.start_time
  end

  def short_job_names
    Test::Middleware::TaskResultTrackingMiddleware.job_results.keys.
      map { _1.sub('Test::Tasks::', '') }
  end
end
