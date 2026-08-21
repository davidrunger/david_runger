class AuthenticatedSessionsController < ApplicationController
  def revoke
    authenticated_session = current_user.authenticated_sessions.
      visible_to_user.
      active.
      find(params.expect(:id))
    authorize(authenticated_session)
    current_session = authenticated_session.current_for?(session, :user)

    authenticated_session.revoke!
    if current_session
      sign_out(:user)
    end

    flash[:notice] = 'Session logged out.'
    redirect_to(current_session ? root_path : my_account_path)
  end
end
