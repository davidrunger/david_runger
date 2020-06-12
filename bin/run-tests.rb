#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './test/runner.rb'

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
end

Test::Runner.run_once_config_is_confirmed
