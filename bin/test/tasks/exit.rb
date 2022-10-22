# frozen_string_literal: true

class Test::Tasks::Exit < Pallets::Task
  include Test::TaskHelpers

  def run
    @overall_finish_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    print_individual_task_times
    print_overall_time_and_parallelism
    print_failed_commands
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
    sorted_job_results.
      each do |task_name, result_hash|
        exit_code = result_hash[:exit_code]
        run_time = result_hash[:run_time]
        exit_message = "exited with #{exit_code}"
        exit_message_color = (exit_code == 0) ? :green : :red
        colorized_exit_message = exit_message.public_send(exit_message_color)
        puts(
          "#{task_name.sub('Test::Tasks::', '').rjust(max_job_name_length)} : " \
          "#{colorized_exit_message} " \
          "(took #{run_time.round(3).to_s.yellow} seconds)",
        )
      end
  end

  def print_overall_time_and_parallelism
    puts("\n")
    puts("Wall clock elapsed time: #{overall_wall_clock_time.round(3).to_s.yellow}")
    total_task_time = job_results.sum { |_key, value| value[:run_time] }
    puts("Total task time: #{total_task_time.round(3).to_s.yellow}")
    puts("Parallelism: #{total_task_time.fdiv(overall_wall_clock_time).round(3).to_s.yellow}")
  end

  def print_failed_commands
    sorted_job_results
    printed_header = false
    sorted_job_results.each do |task_name, result_hash|
      failed_commands = Array(result_hash[:failed_commands])
      next if failed_commands.empty?

      puts("\n=== #{'Failed commands'.red} ===") if !printed_header
      printed_header = true

      failed_commands.each do |failed_command|
        puts("#{task_name}: #{failed_command.red}")
      end
    end
  end

  def overall_wall_clock_time
    @overall_finish_time - Test::Runner.start_time
  end

  def short_job_names
    job_results.keys.map { _1.sub('Test::Tasks::', '') }
  end

  def job_results
    Test::Middleware::TaskResultTrackingMiddleware.job_results
  end

  def sorted_job_results
    job_results.sort_by do |_task_name, result_hash|
      [result_hash[:exit_code], result_hash[:run_time]]
    end
  end
end
