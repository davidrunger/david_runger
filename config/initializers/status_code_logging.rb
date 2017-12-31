ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*args|
  payload = args.extract_options!
  status_code = payload[:status]
  # round down to the nearest hundred, e.g. 404 => 400
  status_code_class = (status_code / 100) * 100
  StatsD.increment("response.#{status_code_class}")
end
