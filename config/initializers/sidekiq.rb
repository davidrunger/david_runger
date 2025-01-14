unless IS_DOCKER_BUILD
  Sidekiq.strict_args!

  # We'll give Sidekiq db 1 (by default). The app uses db 0 for its direct uses.
  db = Integer(ENV.fetch('REDIS_DATABASE_NUMBER', 1))
  redis_options = RedisOptions.new(db:)

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_options.url }
  end

  Sidekiq.configure_server do |config|
    # :nocov:
    config.redis = { url: redis_options.url }

    require 'sidekiq_ext/job_logger'
    config[:job_logger] = SidekiqExt::JobLogger

    if Rails.env.development?
      require 'sidekiq_ext/server_middleware/bullet'

      config.server_middleware do |chain|
        unless IS_DOCKER
          chain.add(SidekiqExt::ServerMiddleware::Bullet)
        end
      end
    end
    # :nocov:
  end
end
