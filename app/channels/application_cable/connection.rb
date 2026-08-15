class ApplicationCable::Connection < ActionCable::Connection::Base
  identified_by :current_user, :authenticated_session_identifier

  def connect
    self.current_user = find_verified_user
    authenticated_session = AuthenticatedSessions::Registry.current(request.session, :user)

    unless (
      authenticated_session&.belongs_to_authenticatable?(current_user) &&
      valid_impersonation_parent?(authenticated_session)
    )
      reject_unauthorized_connection
    end

    self.authenticated_session_identifier = authenticated_session.identifier
    authenticated_session.record_activity!(request)
    @ip = request.remote_ip
  end

  private

  def find_verified_user
    env['warden'].user || reject_unauthorized_connection
  end

  def valid_impersonation_parent?(authenticated_session)
    return true unless authenticated_session.authentication_kind == 'admin_impersonation'

    parent = authenticated_session.initiated_by_authenticated_session
    parent&.active? && parent.identifier == request.session[
      AuthenticatedSessions::Registry.session_key(:admin_user),
    ] && parent.belongs_to_authenticatable?(env['warden'].user(:admin_user))
  end
end
