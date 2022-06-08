# frozen_string_literal: true

module RedisOptions
  def self.options(db:)
    url_base =
      case Rails.env
      when 'development', 'test' then 'redis://localhost:6379'
      # check the ENV var for Heroku review app deployments (since they cannot decode credentials)
      else Rails.application.credentials.redis&.fetch(:tls_url) || ENV.fetch('REDIS_TLS_URL')
      end
    { url: "#{url_base}/#{db}", ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
  end
end
