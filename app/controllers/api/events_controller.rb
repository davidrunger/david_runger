class Api::EventsController < Api::BaseController
  # Some events are sent using navigator.sendBeacon, which doesn't include the CSRF token.
  skip_before_action :verify_authenticity_token, only: %i[create]

  # We want to be able to track clicks from logged out users.
  skip_before_action :authenticate_user!, only: %i[create]

  def create
    authorize(Event)

    event = Event.create_with_stack_trace!(
      admin_user: current_admin_user,
      data: params[:data],
      ip: request.remote_ip,
      type: params[:type],
      user: current_user,
      user_agent: request.user_agent,
    )

    FetchIpInfoForRecord.perform_async(event.class.name, event.id)

    head :created
  end
end
