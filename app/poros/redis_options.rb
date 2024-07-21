class RedisOptions
  prepend MemoWise

  def initialize(db: nil)
    @db = db || default_db_number
  end

  memo_wise \
  def url
    "#{url_without_db}/#{@db}"
  end

  private

  memo_wise \
  def url_without_db
    case ENV.fetch('RAILS_ENV')
    when 'development', 'test' then ENV.fetch('REDIS_URL', 'redis://localhost:6379')
    else ENV.fetch('REDIS_URL')
    end
  end

  memo_wise \
  def default_db_number
    if defined?(Rails) && Rails.env.test?
      # piggyback on the Postgres DB_SUFFIX ENV variable to choose a Redis DB number
      case ENV.fetch('DB_SUFFIX', nil)
      when '_unit', nil then 4
      when '_api' then 5
      when '_html' then 6
      when '_feature' then 7
      else raise('Unexpected DB_SUFFIX!')
      end
    else
      0
    end
  end
end
