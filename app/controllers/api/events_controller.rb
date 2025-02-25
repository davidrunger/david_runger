class Api::EventsController < Api::BaseController
  # Events are sent using navigator.sendBeacon, which doesn't include the CSRF token.
  skip_before_action :verify_authenticity_token, only: %i[create]

  # We want to be able to track clicks from logged out users.
  skip_before_action :authenticate_user!, only: %i[create]

  def create
    authorize(Event)

    event = Event.create_with_stack_trace!(
      admin_user: current_admin_user,
      data: payload_data[:data],
      ip: request.remote_ip,
      type: payload_data[:type],
      user: current_user,
      user_agent: request.user_agent,
    )

    FetchIpInfoForRecord.perform_async(event.class.name, event.id)

    head :created
  end

  private

  def payload_data
    JSON.parse(request.raw_post).with_indifferent_access
  end
end
