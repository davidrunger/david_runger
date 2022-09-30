# frozen_string_literal: true

redis_options = RedisOptions.new

redis_config = RedisClient.config(url: redis_options.url)
$redis_pool = redis_config.new_pool(size: Integer(ENV.fetch('RAILS_MAX_THREADS', 3)))

$redis_rb_pool =
  ConnectionPool.new(size: 1, timeout: 1) do
    Redis.new(url: redis_options.url)
  end
