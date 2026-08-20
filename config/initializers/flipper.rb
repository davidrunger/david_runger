Flipper.configure do |config|
  config.default do
    # Use the DB_SUFFIX-specific Redis database in test; use the default in development.
    redis_options = RedisOptions.new
    adapter = Flipper::Adapters::Redis.new(Redis.new(url: redis_options.url))
    Flipper.new(adapter)
  end
end
