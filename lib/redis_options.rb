# frozen_string_literal: true

module RedisOptions
  def self.options(db:)
    url_base =
      case Rails.env
      when 'development', 'test' then 'redis://localhost:6379'
      else ENV.fetch('REDIS_URL')
      end
    { url: "#{url_base}/#{db}" }
  end
end
