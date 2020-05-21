# frozen_string_literal: true

# this quiets logging of 404s
# modified from https://github.com/roidrage/lograge/issues/146#issuecomment-255337408
module DavidRunger::DebugExceptionsPatch
  def log_error(env, wrapper)
    exception = wrapper.exception
    if exception.is_a?(ActionController::RoutingError)
      data = {
        method: env.method,
        path: env.path,
        status: wrapper.status_code,
        exception: "#{exception.class.name}[#{exception.message}]",
      }
      formatted_message = Lograge.formatter.call(data)
      logger(env).public_send(Lograge.log_level, formatted_message)
    else
      super(env, wrapper)
    end
  end
end

ActionDispatch::DebugExceptions.prepend(DavidRunger::DebugExceptionsPatch)

module PresenceBangMonkeypatch
  def presence!(error_message = nil)
    if present?
      self
    else
      error_message ||= "Expected object to be `present?` but was #{inspect}"
      raise(error_message)
    end
  end
end
Object.prepend(PresenceBangMonkeypatch)
