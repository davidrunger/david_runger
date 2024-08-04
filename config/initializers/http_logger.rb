if Rails.env.development? && !IS_DOCKER
  # :nocov:
  HttpLogger.log_headers = true
  # :nocov:
end
