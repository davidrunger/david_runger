# frozen_string_literal: true

Flipper.configure do |config|
  config.default do
    # Use a separate redis DB in test so settings don't mix with development config.
    db_number = Rails.env.test? ? 3 : 0
    redis_options = RedisOptions.new(db: db_number)
    adapter = Flipper::Adapters::Redis.new(Redis.new(url: redis_options.url))
    Flipper.new(adapter)
  end
end
