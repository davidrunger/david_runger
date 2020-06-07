# frozen_string_literal: true

# See comments in config/initializers/sidekiq.rb for rationale re: pool size of 2.
$redis_pool = ConnectionPool.new(size: 4, timeout: 1) { Redis.new }
