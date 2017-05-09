ActiveSupport::Notifications.subscribe('process_action.action_controller') do |_name, _started, _finished, _unique_id, payload|
  params = payload[:params]
  request_uuid = params['request_uuid']
  pre_stashed_data = JSON.parse($redis.get(request_uuid)) if request_uuid.present?
  Request.create!(
    user_id: pre_stashed_data&.dig('user_id'),
    url: pre_stashed_data&.dig('url'),
    format: payload[:format],
    method: pre_stashed_data&.dig('method'),
    status: payload[:status],
    handler: pre_stashed_data&.dig('handler'),
    params: pre_stashed_data&.dig('params'),
    referer: pre_stashed_data&.dig('referer'),
    view: payload[:view_runtime],
    db: payload[:db_runtime],
    ip: pre_stashed_data&.dig('ip'),
    user_agent: pre_stashed_data&.dig('user_agent'),
    requested_at: pre_stashed_data&.dig('requested_at'),
  )
end
