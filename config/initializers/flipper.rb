# frozen_string_literal: true

Flipper.configure do |config|
  config.default do
    # See comments in config/initializers/sidekiq.rb for Redis connection distribution logic/details
    adapter = Flipper::Adapters::Redis.new(Redis.new)
    Flipper.new(adapter)
  end
end
