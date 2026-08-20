class RedisOptions
  prepend Memoization

  TEST_DB_NUMBERS_BY_SUFFIX = {
    '_unit' => 4,
    '_api' => 5,
    '_html' => 6,
    '_feature_a' => 7,
    '_feature_b' => 8,
    '_feature_c' => 9,
  }.freeze

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
    db_suffix = ENV.fetch('DB_SUFFIX', '_unit')
    base_db_number =
      TEST_DB_NUMBERS_BY_SUFFIX.fetch(db_suffix) { raise('Unexpected DB_SUFFIX!') }

    sidekiq ? base_db_number + TEST_DB_NUMBERS_BY_SUFFIX.size : base_db_number
  end

  memoize \
  def rails_test?
    defined?(Rails) && Rails.env.test?
  end
end
