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
    total:
      # Heroku adds an `X-Request-Start` header ("unix timestamp (milliseconds) when the request was
      # received by the router") https://devcenter.heroku.com/articles/http-routing
      if (request_start_time_in_ms = payload[:headers]['HTTP_X_REQUEST_START'].presence&.to_f)
        # number of milliseconds (rounded to integer) since the request was received by the router
        ((Time.current.to_f - request_start_time_in_ms.fdiv(1_000.0)) * 1_000.0).round
      end,
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
