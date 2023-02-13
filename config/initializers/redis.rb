# frozen_string_literal: true

redis_options = RedisOptions.new

redis_config = RedisClient.config(url: redis_options.url)
$redis_pool = redis_config.new_pool(size: Integer(ENV.fetch('RAILS_MAX_THREADS', 3)))
