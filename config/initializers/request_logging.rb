# frozen_string_literal: true

ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*args|
  payload = args.extract_options!
  params = payload[:params]
  request_uuid = params['request_uuid']

  if request_uuid.blank?
    Rails.logger.warn(<<-LOG.squish)
      Request UUID for request logging was blank.
      request_uuid=#{request_uuid.inspect}
    LOG
    Rollbar.warn(
      Request::CreateRequestError.new('Request UUID for request logging was blank'),
      request_uuid: request_uuid,
    )
    next
  end

  stashed_json = $redis.get(request_uuid)
  if stashed_json.blank?
    Rails.logger.warn(<<-LOG.squish)
      Stashed JSON for request logging was blank.
      stashed_json=#{stashed_json.inspect}
      request_uuid=#{request_uuid.inspect}
    LOG
    Rollbar.warn(
      Request::CreateRequestError.new('Stashed JSON for request logging was blank'),
      stashed_json: stashed_json,
      request_uuid: request_uuid,
    )
    next
  end

  stashed_data = JSON.parse(stashed_json)

  next if stashed_data['admin'] == true

  params = stashed_data['params']

  next if DavidRunger::LogSkip.should_skip?(params: params)

  user_id = stashed_data['user_id']
  requested_at = stashed_data['requested_at']
  request_attributes = {
    user_id: user_id,
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
    requested_at: requested_at,
  }

  if user_id.present?
    user = User.find_by(id: user_id)
    user&.update!(last_activity_at: requested_at)
  end

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
