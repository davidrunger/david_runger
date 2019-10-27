# frozen_string_literal: true

class Middleware::SetConfigServerMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    Runger.config.memoize_settings_from_redis
    @app.call(env)
  end
end
