class DavidRunger::LogBuilder
  # these params are logged already or unimportant
  OMITTED_PARAMS = %w[controller action format id request_uuid].map(&:freeze).freeze

  def initialize(event)
    @event = event
  end

  def extra_logged_data
    {
      params: params_log,
      exception: exception_log,
      user_id: user_id_log,
    }.compact
  end

  private

  def payload
    @event.payload
  end

  def exception_log
    exception = payload[:exception]

    if exception.present?
      exception_class, exception_message = exception
      "#{exception_class}[#{exception_message}]"
    end
  end

  def params_log
    payload[:params].except(*OMITTED_PARAMS)
  end

  def user_id_log
    payload[:user_id] # comes from ApplicationController#append_info_to_payload
  end
end
