module Middleware ; end

class Middleware::Early
  def initialize(app)
    @app = app
  end

  def call(env)
    # puts("Requested #{env['ORIGINAL_FULLPATH']} .")

    status, headers, response = @app.call(env)

    [status, headers, response]
  end
end
