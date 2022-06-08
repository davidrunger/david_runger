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

# See comments in config/initializers/sidekiq.rb for rationale re: pool size of 2.
$redis_pool =
  ConnectionPool.new(size: 2, timeout: 1) do
    Redis.new(**RedisOptions.options(db: db_number))
  end
