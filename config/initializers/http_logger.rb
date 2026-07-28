if Rails.env.development? && !IS_DOCKER
  # simplecov:disable
  HttpLogger.configure do |config|
    config.log_headers = true
  end
  # simplecov:enable
end
