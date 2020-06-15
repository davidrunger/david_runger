# frozen_string_literal: true

class Test::Middleware::TaskResultTrackingMiddleware
  class << self
    attr_reader :job_results

    def call(_worker, job, _context)
      job_name = job['task_class']
      @job_results ||= Hash.new { |hash, key| hash[key] = {} }

      # https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      yield

      stop_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      elapsed_time = stop_time - start_time
      @job_results[job_name][:run_time] = elapsed_time
    rescue => error
      puts("Error occurred ('exited with 1') in Pallets runner: #{error.inspect}".red)
      puts(error.backtrace)
      exit(1)
    end
  end
end
