# this quiets logging of 404s
# modified from https://github.com/roidrage/lograge/issues/146#issuecomment-255337408
module QuietRoutingErrorsMonkeypatch
  def log_error(request, wrapper)
    exception = wrapper.exception
    if exception.is_a?(ActionController::RoutingError)
      data = {
        method: request.method,
        path: request.fullpath,
        status: wrapper.status_code,
        exception: "#{exception.class.name}[#{exception.message}]",
      }
      formatted_message = Lograge.formatter.call(data)
      logger(request).public_send(Lograge.log_level, formatted_message)
    else
      super
    end
  end
end

ActionDispatch::DebugExceptions.prepend(QuietRoutingErrorsMonkeypatch)
