# frozen_string_literal: true

# I'm not sure why it's necessary to explicitly define this module; I thought zeitwerk is supposed
# to do it for us. Maybe it's because it gets loaded so early.
module Middleware; end

class Middleware::SetConfigServerMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    Runger.config.memoize_settings_from_redis
    @app.call(env)
  end
end
