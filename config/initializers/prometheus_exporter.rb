if IS_DOCKER_BUILT
  # :nocov:
  require 'prometheus_exporter/middleware'

  Rails.application.middleware.unshift(PrometheusExporter::Middleware, instrument: :prepend)
  # :nocov:
end
