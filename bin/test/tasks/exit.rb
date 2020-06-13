# frozen_string_literal: true

class Test::Tasks::Exit < Pallets::Task
  include Test::TaskHelpers

  def run
    overall_finish_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    # print the run times and exit codes for all jobs in this pallets run
    puts("\n")
    max_job_name_length =
      TaskResultTrackingMiddleware.job_results.keys.
        map { _1.sub('Test::Tasks::', '') }.map(&:size).
        max
    TaskResultTrackingMiddleware.job_results.
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

    # print overall times and parallelism
    puts("\n")
    overall_start_time = Test::Runner.start_time
    overall_wall_clock_time = overall_finish_time - overall_start_time
    puts("Wall clock elapsed time: #{overall_wall_clock_time.round(3).to_s.yellow}")
    total_task_time = TaskResultTrackingMiddleware.job_results.map { _2[:run_time] }.inject(:+)
    puts("Total task time: #{total_task_time.round(3).to_s.yellow}")
    puts("Parallism: #{total_task_time.fdiv(overall_wall_clock_time).round(3).to_s.yellow}")

    puts("\n")
    puts("Exiting with code #{Test::Runner.exit_code}")
    exit(Test::Runner.exit_code)
  end
end
