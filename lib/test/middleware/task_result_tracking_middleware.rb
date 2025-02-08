class Test::Middleware::TaskResultTrackingMiddleware
  class << self
    attr_reader :job_results

    def call(_worker, job, _context)
      job_name = job['task_class']
      @job_results ||= Hash.new { |hash, key| hash[key] = {} }

      start_time = Time.current
      # https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
      start_time_monotonic = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      yield

      stop_time_monotonic = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      stop_time = Time.current

      elapsed_time = stop_time_monotonic - start_time_monotonic

      job_hash = @job_results[job_name]
      job_hash[:start_time] = start_time
      job_hash[:stop_time] = stop_time
      job_hash[:run_time] = elapsed_time
    rescue => error
      puts(AmazingPrint::Colors.red(
        "Error occurred ('exited with 1') in Pallets runner: #{error.inspect}",
      ))
      puts(error.backtrace)
      exit(1)
    end
  end
end
