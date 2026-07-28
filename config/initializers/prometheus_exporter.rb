if IS_DOCKER_BUILT
  # simplecov:disable
  require 'prometheus_exporter/middleware'

  Rails.application.middleware.unshift(PrometheusExporter::Middleware, instrument: :prepend)
  # simplecov:enable
end
