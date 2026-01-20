unless IS_DOCKER_BUILD
  Sidekiq.strict_args!

  # We'll give Sidekiq db 1 (by default, except in tests, where this is ignored).
  # (The app uses db 0 for its direct uses.)
  db = Integer(ENV.fetch('REDIS_DATABASE_NUMBER', 1))
  redis_options = RedisOptions.new(db:, sidekiq: true)

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_options.url }
  end

  Sidekiq.configure_server do |config|
    # :nocov:
    config.redis = { url: redis_options.url }

    require 'sidekiq_ext/job_logger'
    config[:job_logger] = SidekiqExt::JobLogger

    # Prometheus Exporter >>>
    if IS_DOCKER_BUILT
      require 'prometheus_exporter/instrumentation'

      config.server_middleware do |chain|
        chain.add(PrometheusExporter::Instrumentation::Sidekiq)
      end

      config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler

      config.on(:startup) do
        PrometheusExporter::Instrumentation::Process.start(type: 'sidekiq')
        PrometheusExporter::Instrumentation::SidekiqProcess.start
        PrometheusExporter::Instrumentation::SidekiqQueue.start
        PrometheusExporter::Instrumentation::SidekiqStats.start
      end
    end
    # <<< Prometheus Exporter

    if Rails.env.local? && !IS_DOCKER
      config.server_middleware do |chain|
        require 'prosopite/middleware/sidekiq'
        chain.add(Prosopite::Middleware::Sidekiq)
      end
    end
    # :nocov:
  end
end
