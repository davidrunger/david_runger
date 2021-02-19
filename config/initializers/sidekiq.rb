# frozen_string_literal: true

require 'sidekiq-scheduler' if Sidekiq.server?

# We'll give Sidekiq db 1. The app uses db 0 for its direct uses.
build_sidekiq_redis_connection = proc { Redis.new(db: 1) }

Sidekiq.configure_client do |config|
  # Sidekiq Client Connection Pool size:
  # We have 20 connections total from Heroku Redis Hobby Dev plan
  # ... minus 7 connections used for the Sidekiq server below ...
  # ... minus 1 for `rails console` use and padding ...
  # ... leaves us with 12 connections total for other uses.
  # We'll distribute those Redis connections like so:
  # - 2 connections for the Sidekiq client pool (the line below) * 2 because both the web server and
  #   the Sidekiq process can invoke Sidekiq jobs (i.e. can use a Sidekiq client connection)
  # - 2 for the application (in config/initializers/redis.rb) * 2 for the same reason
  # - 1 for Flipper (in config/initializers/flipper.rb) * 2 for the same reason
  # - 2 for ActionCable
  config.redis = ConnectionPool.new(size: 2, &build_sidekiq_redis_connection)
end

Sidekiq.configure_server do |config|
  # Sidekiq Server Connection Pool size:
  # This is `(max_)concurrency + 5`.
  # For concurrency (2), see config/sidekiq.yml.
  # For why we are adding 5, see https://github.com/mperham/sidekiq/wiki/Using-Redis#complete-control
  # :nocov:
  config.redis = ConnectionPool.new(size: 7, &build_sidekiq_redis_connection)

  require 'sidekiq_ext/job_logger'
  config.options[:job_logger] = SidekiqExt::JobLogger

  if Rails.env.development?
    require 'sidekiq_ext/server_middleware/bullet'

    config.server_middleware do |chain|
      chain.add(SidekiqExt::ServerMiddleware::Bullet)
    end
  end
  # :nocov:
end
