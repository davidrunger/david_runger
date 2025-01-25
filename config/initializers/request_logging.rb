ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*args|
  payload = args.extract_options!

  controller_name, params = payload.values_at(:controller, :params)

  if SaveRequest::SkipChecker.new(params:).skip?
    next
  end

  controller_klass = controller_name.constantize
  # We won't log requests to non-ApplicationController controllers (e.g. Flipper & Sidekiq engines)
  # rubocop:disable Style/InvertibleUnlessCondition
  next unless controller_klass <= ApplicationController
  # rubocop:enable Style/InvertibleUnlessCondition

  request_id = payload[:headers]['action_dispatch.request_id']

  if request_id.blank?
    Rails.error.report(
      Error.new(Request::CreateRequestError, 'Request UUID for request logging was blank'),
      context: { request_id: },
    )

    next
  end

  final_request_data = {
    status: payload[:status] || (payload[:exception].present? ? 500 : nil),
    view: payload[:view_runtime],
    db: payload[:db_runtime],
    total:
      # Our NGINX config adds an `X-Request-Start` header, which is the unix
      # timestamp (in seconds, with milliseconds decimal precision) when the request was
      # received by NGINX.
      # rubocop:disable Lint/NumberConversion
      if (request_start_time_in_seconds = payload[:headers]['HTTP_X_REQUEST_START'].presence&.to_f)
        # rubocop:enable Lint/NumberConversion
        # number of milliseconds (rounded to integer) since the request was received by the router
        ((Time.current.to_f - request_start_time_in_seconds) * 1_000.0).round
      end,
  }

  $redis_pool.with do |conn|
    conn.call(
      'setex',
      "request_data:#{request_id}:final",
      RequestRecordable::REQUEST_DATA_TTL,
      final_request_data.to_json,
    )
  end

  SaveRequest.perform_async(request_id)

  nil
end
