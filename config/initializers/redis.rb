# frozen_string_literal: true

db_number =
  if Rails.env.test?
    # piggyback on the Postgres DB_SUFFIX ENV variable to choose a Redis DB number
    case ENV.fetch('DB_SUFFIX', nil)
    when '_unit', nil then 4
    when '_api' then 5
    when '_html' then 6
    when '_feature' then 7
    end
  else
    # :nocov:
    0
    # :nocov:
  end

redis_options = RedisOptions.new(db: db_number)
redis_config = RedisClient.config(url: redis_options.url)
$redis_pool = redis_config.new_pool(size: Integer(ENV.fetch('RAILS_MAX_THREADS', 3)))

$redis_rb_pool =
  ConnectionPool.new(size: 1, timeout: 1) do
    Redis.new(url: RedisOptions.new(db: db_number).url)
  end
