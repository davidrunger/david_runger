module Middleware ; end

class Middleware::PublicTelemetryBodyLimiter
  MAX_BODY_BYTES = 16.kilobytes
  TELEMETRY_PATH_REGEX = %r{\A/api/(?:csp_reports|events)(?:\.[^/]+)?/?\z}
  TOO_LARGE_BODY = 'Telemetry request body is too large.'

  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless limited_request?(env)

    declared_body_bytes = Integer(env.fetch('CONTENT_LENGTH', 0), exception: false) || 0
    return content_too_large_response if declared_body_bytes > MAX_BODY_BYTES

    request_body = env.fetch('rack.input')
    body = request_body.read(MAX_BODY_BYTES + 1).to_s
    return content_too_large_response if body.bytesize > MAX_BODY_BYTES

    request_body.rewind
    @app.call(env)
  end

  private

  def limited_request?(env)
    env['REQUEST_METHOD'] == 'POST' && env['PATH_INFO'].match?(TELEMETRY_PATH_REGEX)
  end

  def content_too_large_response
    [
      413,
      {
        'content-length' => TOO_LARGE_BODY.bytesize.to_s,
        'content-type' => 'text/plain; charset=utf-8',
      },
      [TOO_LARGE_BODY],
    ]
  end
end
