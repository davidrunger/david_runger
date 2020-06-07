# frozen_string_literal: true

require 'sidekiq-scheduler' if Sidekiq.server?

# We'll give Sidekiq db 1. The app uses db 0 for its direct uses.
build_sidekiq_redis_connection = proc { Redis.new(db: 1) }

Sidekiq.configure_client do |config|
  # Sidekiq Client Connection Pool size:
  # We have 20 connections total from Heroku Redis Hobby Dev plan
  # ... minus 7 connections used for Sidekiq below ...
  # ... minus 3 connections for `rails console` and general padding ...
  # ... leaves us with 10 connections total for the Rails server processes.
  # We are running 2 processes, so each process gets 5 connections.
  # We'll distribute those Redis connections used by each Rails server process like so:
  # * 2 connections for the Sidekiq client pool (the line below) (per process)
  # * 2 for the application (per process)
  # * 1 for Flipper (per process)
  config.redis = ConnectionPool.new(size: 2, &build_sidekiq_redis_connection)
end

Sidekiq.configure_server do |config|
  # Sidekiq Server Connection Pool size:
  # This is `(max_)concurrency + 5`.
  # For concurrency (2), see config/sidekiq.yml.
  # For why we are adding 5, see https://github.com/mperham/sidekiq/wiki/Using-Redis#complete-control
  config.redis = ConnectionPool.new(size: 7, &build_sidekiq_redis_connection)

  if Rails.env.development?
    config.server_middleware do |chain|
      require_relative '../../lib/middleware/set_config_sidekiq_middleware'
      chain.add(Middleware::SetConfigSidekiqMiddleware)

      require_relative '../../lib/middleware/sidekiq_dev_logging'
      chain.add(Middleware::SidekiqDevLogging)
      # silence the default Sidekiq logger
      class ::Sidekiq::JobLogger
        def call(*_args)
          yield
        end
      end
    end
  end
end
