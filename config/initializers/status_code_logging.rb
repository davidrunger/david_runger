# frozen_string_literal: true

ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*args|
  payload = args.extract_options!
  params = payload[:params]
  next if DavidRunger::LogSkip.should_skip?(params: params)

  # Devise annoyingly sets payload[:status] to 401 in some cases even when an exception has occurred
  status_code = payload[:exception].present? ? 500 : payload[:status]
  # round down to the nearest hundred, e.g. 404 => 400
  status_code_class = (status_code / 100) * 100
  StatsD.increment("response.#{status_code_class}")
end
