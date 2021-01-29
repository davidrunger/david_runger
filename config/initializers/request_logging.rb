# frozen_string_literal: true

ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*args|
  payload = args.extract_options!

  controller_name = payload[:controller]
  next if controller_name == 'AnonymousController' # this occurs in tests

  controller_klass = controller_name.constantize
  # We won't log requests to non-ApplicationController controllers (e.g. Flipper & Sidekiq engines)
  next unless controller_klass <= ApplicationController

  request_id = payload[:headers]['action_dispatch.request_id']
  if request_id.blank?
    Rails.logger.warn(<<-LOG.squish)
      Request UUID for request logging was blank.
      request_id=#{request_id.inspect}
    LOG
    Rollbar.warn(
      Request::CreateRequestError.new('Request UUID for request logging was blank'),
      request_id: request_id,
    )
    next
  end

  final_request_data = {
    status: payload[:status] || (payload[:exception].present? ? 500 : nil),
    view: payload[:view_runtime],
    db: payload[:db_runtime],
  }

  $redis_pool.with do |conn|
    conn.setex(
      "request_data:#{request_id}:final",
      ::RequestRecordable::REQUEST_DATA_TTL,
      final_request_data.to_json,
    )
  end

  SaveRequest.perform_async(request_id)

  nil
end
