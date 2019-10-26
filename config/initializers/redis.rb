# frozen_string_literal: true

rails_max_threads = Integer(ENV.fetch('RAILS_MAX_THREADS') { 5 })
$redis_pool = ConnectionPool.new(size: rails_max_threads, timeout: 1) { Redis.new }
