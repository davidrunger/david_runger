# frozen_string_literal: true

class ErrorSubscriber
  SEVERITY_TO_METHOD = {
    error: :error,
    warning: :warn,
    info: :info,
  }.freeze

  def report(error, **kwargs)
    # Instead, we'll use the controller_action (set via set_controller_action_in_context).
    kwargs[:context] = kwargs[:context].except(:controller)

    if error.class.name.start_with?('Sidekiq::JobRetry::')
      # Only write a log line because the Rollbar integration will automatically send to Rollbar.
      write_log_line(error.cause, **kwargs)
    else
      write_log_line(error, **kwargs)

      # Unhandled errors will be picked up by Rollbar integrations, so don't send them here, too.
      # Here, we will only report _handled_ (manually sent) errors.
      if kwargs[:handled]
        send_to_rollbar(error, **kwargs)
      end
    end
  end

  private

  def write_log_line(error, handled:, severity:, context:, source: nil)
    log_line =
      "[error-report] #{error.class.name} : #{error.message} | " \
      "handled=#{handled.present?} source=#{source}"

    if context.respond_to?(:map) && context.all? { _1.size == 2 }
      log_line << ' '
      log_line << context.map { |key, value| "#{key}=#{value.inspect}" }.join(' ')
    end

    log_line.strip!

    Rails.logger.public_send(severity_method(severity), log_line)
  end

  def send_to_rollbar(error, handled:, severity:, context:, source: nil)
    context = { handled: handled.present?, source: }.compact.merge(context)

    Rollbar.log(severity_method(severity), error, context)
  end

  def severity_method(severity)
    SEVERITY_TO_METHOD.fetch(severity)
  end
end

Rails.error.subscribe(ErrorSubscriber.new)
