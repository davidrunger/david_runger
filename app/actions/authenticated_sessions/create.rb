class AuthenticatedSessions::Create < ApplicationAction
  requires :authenticatable, ActiveRecord::Base
  requires :authentication_kind, String
  requires :request, ActionDispatch::Request
  requires :initiated_by_authenticated_session, AuthenticatedSession, NilClass

  returns :authenticated_session, AuthenticatedSession

  def execute
    result.authenticated_session = authenticatable.authenticated_sessions.create!(
      authentication_kind:,
      initial_ip: request.remote_ip,
      latest_ip: request.remote_ip,
      initial_user_agent: request.user_agent.to_s,
      latest_user_agent: request.user_agent.to_s,
      last_active_at: Time.current.change(sec: 0, usec: 0),
      initiated_by_authenticated_session:,
    )

    FetchIpInfoForRecord.perform_async(AuthenticatedSession.name, result.authenticated_session.id)
  end
end
