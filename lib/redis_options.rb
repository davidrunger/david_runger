# frozen_string_literal: true

module RedisOptions
  def self.options(db:)
    url_base =
      case Rails.env
      when 'development', 'test' then 'redis://localhost:6379'
      else production_redis_url
      end
    { url: "#{url_base}/#{db}", ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
  end

  def self.production_redis_url
    ENV.fetch('EMERGENCY_REDIS_TLS_URL', nil) ||
      Rails.application.credentials.redis&.fetch(:tls_url) ||
      # check the ENV var for Heroku review app deployments (since they cannot decode credentials)
      ENV.fetch('REDIS_TLS_URL', nil)
  end
end
