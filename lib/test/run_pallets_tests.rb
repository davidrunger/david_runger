require_relative '../../config/initializers/monkeypatches/faraday.rb'
require_relative 'middleware/exit_on_failure_middleware.rb'
require_relative 'middleware/task_result_tracking_middleware.rb'
require_relative 'runner.rb'

Pallets.configure do |c|
  concurrency = Integer(ENV.fetch('PALLETS_CONCURRENCY'))
  puts("Pallets concurrency: #{concurrency}")

  c.concurrency = concurrency
  c.max_failures = 0
  c.backend_args = { url: 'redis://127.0.0.1:6379/15' } # Use redis db 15 (to avoid conflicts).
  c.middleware << Test::Middleware::ExitOnFailureMiddleware
  c.middleware << Test::Middleware::TaskResultTrackingMiddleware
end

Test::Runner.run_once_config_is_confirmed
