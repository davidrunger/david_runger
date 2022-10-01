# frozen_string_literal: true

Sidekiq.strict_args!

# We'll give Sidekiq db 1. The app uses db 0 for its direct uses.
redis_options = RedisOptions.new(db: 1)

Sidekiq.configure_client do |config|
  config.redis = { url: redis_options.url }
end

Sidekiq.configure_server do |config|
  # Sidekiq Server Connection Pool size:
  # This is `(max_)concurrency + 5`.
  # For concurrency (3), see config/sidekiq.yml.
  # For why we are adding 5, see https://github.com/mperham/sidekiq/wiki/Using-Redis#complete-control
  # :nocov:
  config.redis = { url: redis_options.url }

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
