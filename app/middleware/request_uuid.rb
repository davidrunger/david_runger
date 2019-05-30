# frozen_string_literal: true

class RequestUuid
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    request_uuid = SecureRandom.uuid
    request.update_param('request_uuid', request_uuid)
    @app.call(env)
  end
end
