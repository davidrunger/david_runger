ActiveAdmin.register_page('My Sessions') do
  page_action :revoke, method: :patch do
    authenticated_session = current_admin_user.authenticated_sessions.
      active.
      find(params.expect(:id))
    current_session = authenticated_session.current_for?(session, :admin_user)

    authenticated_session.revoke!
    sign_out(:admin_user) if current_session

    flash[:notice] = 'Session logged out.'
    redirect_to(current_session ? new_admin_user_session_path : admin_my_sessions_path)
  end

  content do
    current_session = AuthenticatedSessions::Registry.current(session, :admin_user)
    sessions = current_admin_user.authenticated_sessions.
      active.
      order(last_active_at: :desc).
      decorate

    para <<~TEXT.squish
      These are the known active sessions for your administrator account. A browser may have
      cleared or expired its cookie without notifying the server.
    TEXT
    table_for sessions do
      column('Current') do |authenticated_session|
        authenticated_session == current_session ? 'Yes' : ''
      end
      column('First seen', &:first_seen)
      column('Last active', &:last_active)
      column('Initial IP', &:initial_ip)
      column :location
      column :isp
      column('Latest IP', &:latest_ip)
      column('Initial client', &:initial_client)
      column('Latest client', &:latest_client)
      column do |authenticated_session|
        button_to(
          'Log out',
          admin_my_sessions_revoke_path(id: authenticated_session),
          method: :patch,
        )
      end
    end
  end
end
