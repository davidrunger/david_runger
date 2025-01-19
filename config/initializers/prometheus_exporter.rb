unless Rails.env.test?
  # :nocov:
  require 'prometheus_exporter/middleware'

  Rails.application.middleware.unshift(PrometheusExporter::Middleware, instrument: :prepend)
  # :nocov:
end
