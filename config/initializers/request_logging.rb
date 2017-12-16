ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*args|
  payload = args.extract_options!
  params = payload[:params]
  request_uuid = params['request_uuid']

  next if request_uuid.blank?

  stashed_json = $redis.get(request_uuid)
  stashed_data = stashed_json.present? ? JSON.parse(stashed_json) : {}

  next if stashed_data['admin'] == true

  params = stashed_data['params']

  next if params['new_relic_ping'].present? && ENV['LOG_NEW_RELIC_PINGS'].blank?

  request_attributes = {
    user_id: stashed_data['user_id'],
    url: stashed_data['url'],
    format: payload[:format],
    method: stashed_data['method'],
    status: payload[:status],
    handler: stashed_data['handler'],
    params: params,
    referer: stashed_data['referer'],
    view: payload[:view_runtime],
    db: payload[:db_runtime],
    ip: stashed_data['ip'],
    user_agent: stashed_data['user_agent'],
    bot: stashed_data['bot'],
    requested_at: stashed_data['requested_at'],
  }

  request = Request.new(request_attributes)
  saved_successfully = request.save
  if !saved_successfully
    Rails.logger.error(<<-LOG.squish)
      Failed to create a Request,
      errors=#{request.errors.to_h},
      stashed_json=#{stashed_json.inspect},
      request_attributes=#{request_attributes.inspect}
    LOG
    Rollbar.error(
      Request::CreateRequestError.new('Failed to save a Request'),
      stashed_json: stashed_json,
      request_attributes: request_attributes,
      errors: request.errors.to_h,
    )
  end
end
