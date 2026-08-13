class ApplicationCable::Connection < ActionCable::Connection::Base
  identified_by :current_user, :authenticated_session_identifier

  def connect
    self.current_user = find_verified_user
    authenticated_session = AuthenticatedSessions::Registry.current(request.session, :user)
    reject_unauthorized_connection unless authenticated_session&.authenticatable == current_user
    reject_unauthorized_connection unless valid_impersonation_parent?(authenticated_session)
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
    ] && parent.authenticatable == env['warden'].user(:admin_user)
  end
end
