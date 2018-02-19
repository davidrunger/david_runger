class DavidRunger::LogBuilder
  # these params are logged already or unimportant
  OMITTED_PARAMS = %w[controller action format id request_uuid].map(&:freeze).freeze

  def initialize(event)
    @event = event
  end

  def extra_logged_data
    {
      exception: exception_log,
      params: params_log,
      status: status_code_log,
      user_id: user_id_log,
    }.compact
  end

  private

  def payload
    @event.payload
  end

  def exception
    payload[:exception]
  end

  def exception_log
    if exception.present?
      exception_class, exception_message = exception
      "#{exception_class}[#{exception_message}]"
    end
  end

  def params_log
    payload[:params].except(*OMITTED_PARAMS)
  end

  def status_code_log
    # Devise annoyingly sets payload[:status] to 401 sometimes even when an exception has occurred
    exception.present? ? 500 : payload[:status]
  end

  def user_id_log
    payload[:user_id] # comes from ApplicationController#append_info_to_payload
  end
end
