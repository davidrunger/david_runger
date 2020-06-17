#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './test/runner.rb'
require_relative './test/middleware/exit_on_failure_middleware.rb'
require_relative './test/middleware/task_result_tracking_middleware.rb'

Pallets.configure do |c|
  c.concurrency = 3
  c.backend = :redis
  c.backend_args = { url: 'redis://127.0.0.1:6379/8' } # use redis db #8 (to avoid conflicts)
  c.serializer = :msgpack
  c.max_failures = 0
  c.logger = Logger.new(STDOUT)
  c.middleware << Test::Middleware::ExitOnFailureMiddleware
  c.middleware << Test::Middleware::TaskResultTrackingMiddleware
end

Test::Runner.run_once_config_is_confirmed
