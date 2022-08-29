# frozen_string_literal: true

require 'sidekiq-scheduler' if Sidekiq.server?

# We'll give Sidekiq db 1. The app uses db 0 for its direct uses.
redis_options = RedisOptions.new(db: 1)
build_sidekiq_redis_connection =
  proc { Sidekiq::RedisClientAdapter.new(url: redis_options.url).new_client }

Sidekiq::RedisConnection.adapter = :redis_client

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 3, &build_sidekiq_redis_connection)
end

Sidekiq.configure_server do |config|
  # Sidekiq Server Connection Pool size:
  # This is `(max_)concurrency + 5`.
  # For concurrency (3), see config/sidekiq.yml.
  # For why we are adding 5, see https://github.com/mperham/sidekiq/wiki/Using-Redis#complete-control
  # :nocov:
  config.redis = ConnectionPool.new(size: 8, &build_sidekiq_redis_connection)

  require 'sidekiq_ext/job_logger'
  config[:job_logger] = SidekiqExt::JobLogger

  if Rails.env.development?
    require 'sidekiq_ext/server_middleware/bullet'

    config.server_middleware do |chain|
      chain.add(SidekiqExt::ServerMiddleware::Bullet)
    end
  end
  # :nocov:
end
