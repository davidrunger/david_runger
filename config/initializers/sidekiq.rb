# frozen_string_literal: true

sidekiq_redis_options = {
  db: 1,
}

Sidekiq.configure_client do |config|
  config.redis = sidekiq_redis_options
end

Sidekiq.configure_server do |config|
  config.redis = sidekiq_redis_options
end
