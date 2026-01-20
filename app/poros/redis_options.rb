class RedisOptions
  prepend Memoization

  def initialize(db: nil, sidekiq: false)
    @db =
      if rails_test?
        test_db_number(sidekiq:)
      else
        db || 0
      end
  end

  memoize \
  def url
    "#{url_without_db}/#{@db}"
  end

  private

  memoize \
  def url_without_db
    case ENV.fetch('RAILS_ENV')
    when 'development', 'test' then ENV.fetch('REDIS_URL', 'redis://localhost:6379')
    else ENV.fetch('REDIS_URL')
    end
  end

  memoize \
  def test_db_number(sidekiq:)
    # Piggyback on the Postgres DB_SUFFIX ENV variable to choose a Redis DB number.
    base_db_number =
      case ENV.fetch('DB_SUFFIX', nil)
      when '_unit', nil then 4
      when '_api' then 5
      when '_html' then 6
      when '_feature_a' then 7
      when '_feature_c' then 8
      else raise('Unexpected DB_SUFFIX!')
      end

    sidekiq ? base_db_number + 5 : base_db_number
  end

  memoize \
  def rails_test?
    defined?(Rails) && Rails.env.test?
  end
end
