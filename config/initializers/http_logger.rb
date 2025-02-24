if Rails.env.development? && !IS_DOCKER
  # :nocov:
  HttpLogger.configure do |config|
    config.log_headers = true
  end
  # :nocov:
end
