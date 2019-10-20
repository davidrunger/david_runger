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

  final_request_data = {
    status: payload[:status] || (payload[:exception].present? ? 500 : nil),
    view: payload[:view_runtime],
    db: payload[:db_runtime],
  }

  $redis.setex(
    "request_data:#{params['request_uuid']}:final",
    ::RequestRecordable::REQUEST_DATA_TTL,
    final_request_data.to_json,
  )

  controller_name = payload[:controller]
  controller = controller_name.constantize
  is_admin_controller = controller.ancestors.include?(Admin::ApplicationController)
  is_pghero_controller = controller_name.start_with?('PgHero::')

  unless is_admin_controller || is_pghero_controller
    SaveRequest.perform_async(params['request_uuid'])
  end

  nil
end
