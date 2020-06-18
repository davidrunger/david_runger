# frozen_string_literal: true

if Rails.configuration.rack_mini_profiler_enabled
  # :nocov:
  require 'rack-mini-profiler'

  Rack::MiniProfilerRails.initialize!(Rails.application)

  Rails.configuration.middleware.move_after(Rack::Deflater, Rack::MiniProfiler)

  Rack::MiniProfiler.config.storage_options = { url: ENV['REDIS_URL'] }
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore

  Rack::MiniProfiler.config.authorization_mode = :whitelist
  # :nocov:
end
