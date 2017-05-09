ActiveSupport::Notifications.subscribe('process_action.action_controller') do |_name, _started, _finished, _unique_id, payload|
  params = payload[:params]
  request_uuid = params['request_uuid']
  stashed_json = request_uuid && $redis.get(request_uuid)
  stashed_data = stashed_json.present? ? JSON.parse(stashed_json) : {}
  Request.create!(
    user_id: stashed_data['user_id'],
    url: stashed_data['url'],
    format: payload[:format],
    method: stashed_data['method'],
    status: payload[:status],
    handler: stashed_data['handler'],
    params: stashed_data['params'],
    referer: stashed_data['referer'],
    view: payload[:view_runtime],
    db: payload[:db_runtime],
    ip: stashed_data['ip'],
    user_agent: stashed_data['user_agent'],
    requested_at: stashed_data['requested_at'],
  )
end
