# frozen_string_literal: true

Flipper.configure do |config|
  config.default do
    # See comments in config/initializers/sidekiq.rb for Redis connection distribution logic/details
    # Use a separate redis DB in test so settings don't mix with development config.
    db_number = Rails.env.test? ? 3 : 0
    adapter = Flipper::Adapters::Redis.new(Redis.new(db: db_number))
    Flipper.new(adapter)
  end
end
