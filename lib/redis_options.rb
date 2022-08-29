# frozen_string_literal: true

class RedisOptions
  extend Memoist

  def initialize(db:)
    @db = db
  end

  memoize \
  def url
    "#{url_without_db}/#{@db}"
  end

  private

  memoize \
  def url_without_db
    case Rails.env
    when 'development', 'test' then 'redis://localhost:6379'
    else ENV.fetch('REDIS_URL')
    end
  end
end
