module RequestLogging
  class CreateRequestError < StandardError ; end

  IGNORED_USER_AGENTS = %w[
    NewRelicPinger
  ]
  IGNORED_USER_AGENTS_REGEX = Regexp.new(IGNORED_USER_AGENTS.join('|'))
end

ActiveSupport::Notifications.subscribe('process_action.action_controller') do |_name, _started, _finished, _unique_id, payload|
  params = payload[:params]
  request_uuid = params['request_uuid']
  stashed_json = request_uuid && $redis.get(request_uuid)
  stashed_data = stashed_json.present? ? JSON.parse(stashed_json) : {}
  next if stashed_data['admin'] == true
  user_agent = stashed_data['user_agent']
  request_attributes = {
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
    user_agent: user_agent,
    bot: stashed_data['bot'],
    requested_at: stashed_data['requested_at'],
  }

  if user_agent =~ RequestLogging::IGNORED_USER_AGENTS_REGEX
    Rails.logger.info(<<-LOG.squish)
      Skipping creation of a Request because user_agent #{user_agent} is in IGNORED_USER_AGENTS.
      Request attributes were #{request_attributes}
    LOG
  else
    request = Request.new(request_attributes)
    if !request.save
      Rails.logger.warn(<<-LOG.squish)
        Failed to create a Request,
        errors=#{request.errors.to_h},
        stashed_json=#{stashed_json.inspect},
        request_attributes=#{request_attributes.inspect}
      LOG
      Rollbar.warning(
        RequestLogging::CreateRequestError.new('Failed to save a Request'),
        stashed_json: stashed_json,
        request_attributes: request_attributes,
        errors: request.errors.to_h,
      )
    end
  end
end
