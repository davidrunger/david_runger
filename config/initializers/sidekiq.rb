# frozen_string_literal: true

require 'sidekiq-scheduler' if Sidekiq.server?

# We'll give Sidekiq db 1. The app uses db 0 for its direct uses.
build_sidekiq_redis_connection = proc { Redis.new(db: 1) }

Sidekiq.configure_client do |config|
  # Sidekiq Client Connection Pool size:
  # We have 20 connections total from Heroku Redis Hobby Dev plan
  # ... minus 7 connections used for the Sidekiq server below ...
  # ... minus 5 connections for `rails console` and general padding ...
  # ... leaves us with 8 connections total for the Rails server process(es).
  # We are running 1 server process, so that process has 8 connections to work with.
  # We'll distribute those Redis connections like so:
  # * 3 connections for the Sidekiq client pool (the line below)
  # * 4 for the application (in config/initializers/redis.rb)
  # * 1 for Flipper (in config/initializers/flipper.rb)
  config.redis = ConnectionPool.new(size: 3, &build_sidekiq_redis_connection)
end

Sidekiq.configure_server do |config|
  # Sidekiq Server Connection Pool size:
  # This is `(max_)concurrency + 5`.
  # For concurrency (2), see config/sidekiq.yml.
  # For why we are adding 5, see https://github.com/mperham/sidekiq/wiki/Using-Redis#complete-control
  # :nocov:
  config.redis = ConnectionPool.new(size: 7, &build_sidekiq_redis_connection)
  # :nocov:
end
