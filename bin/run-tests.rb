#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './test/runner.rb'

class TaskResultTrackingMiddleware
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

Pallets.configure do |c|
  class ExitOnFailureMiddleware
    def self.call(_worker, _job, _context)
      yield
    rescue => error
      puts("Error occurred ('exited with 1') in Pallets runner: #{error.inspect}".red)
      puts(error.backtrace)
      exit(1)
    end
  end

  c.concurrency = 3
  c.backend = :redis
  c.backend_args = { url: 'redis://127.0.0.1:6379/8' } # use redis db #8 (to avoid conflicts)
  c.serializer = :msgpack
  c.job_timeout = 120 # allow 2 minutes for each task to complete
  c.max_failures = 0
  c.logger = Logger.new(STDOUT)
  c.middleware << ExitOnFailureMiddleware
  c.middleware << TaskResultTrackingMiddleware
end

Test::Runner.run_once_config_is_confirmed
