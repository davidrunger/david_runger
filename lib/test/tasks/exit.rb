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
          "(took #{AmazingPrint::Colors.yellow(run_time.round(3).to_s)} seconds)",
        )
      end
  end

  def print_overall_time_and_parallelism
    puts("\n")
    puts(<<~LOG.squish)
      Wall clock elapsed time: #{AmazingPrint::Colors.yellow(overall_wall_clock_time.round(3).to_s)}
    LOG
    total_task_time = job_results.sum { |_key, value| value[:run_time] }
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

  def short_job_names(task_set)
    task_set.map { _1.sub('Test::Tasks::', '') }
  end

  def job_results
    Test::Middleware::TaskResultTrackingMiddleware.job_results
  end

  def sorted_job_results
    job_results.sort_by do |_task_name, result_hash|
      [result_hash[:exit_code], result_hash[:run_time]]
    end
  end

  def max_job_name_length(task_set)
    short_job_names(task_set).map(&:size).max
  end

  def rjusted_short_name(task_name, task_set = job_results.keys)
    task_name.sub('Test::Tasks::', '').rjust(max_job_name_length(task_set))
  end
end
