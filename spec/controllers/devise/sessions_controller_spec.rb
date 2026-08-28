RSpec.describe Devise::SessionsController do
  describe '#destroy' do
    subject(:delete_destroy) { delete(:destroy) }

    before { request.env['devise.mapping'] = Devise.mappings[:user] }

    context 'when a user is signed in' do
      before { sign_in(user) }

      let(:user) { users(:user) }

      context 'when the request format is json', request_format: :json do
        it 'responds with 204' do
          delete_destroy
          expect(response).to have_http_status(204)
        end
      end
    end

    context 'when a User and AdminUser are signed in' do
      let(:user) { users(:user) }
      let(:admin_user) { admin_users(:admin_user) }
      let(:user_authenticated_session) { user.authenticated_sessions.first! }
      let(:admin_authenticated_session) { admin_user.authenticated_sessions.first! }

      before do
        sign_in(user)
        sign_in(admin_user, scope: :admin_user)
        session[AuthenticatedSessions::Registry.session_key(:user)] =
          user_authenticated_session.identifier
        session[AuthenticatedSessions::Registry.session_key(:admin_user)] =
          admin_authenticated_session.identifier
      end

      it 'signs out the User without signing out the AdminUser' do
        delete_destroy

        expect(response).to redirect_to(root_path)
        expect(user_authenticated_session.reload).not_to be_active
        expect(admin_authenticated_session.reload).to be_active
        expect(session).not_to have_key(AuthenticatedSessions::Registry.session_key(:user))
        expect(session[AuthenticatedSessions::Registry.session_key(:admin_user)]).
          to eq(admin_authenticated_session.identifier)
      end

      context 'when the User session is an impersonation' do
        let(:user_authenticated_session) do
          create(
            :authenticated_session,
            authenticatable: user,
            authentication_kind: 'admin_impersonation',
            initiated_by_authenticated_session: admin_authenticated_session,
          )
        end

        it 'ends the impersonation without signing out the AdminUser' do
          delete_destroy

          expect(response).to redirect_to(root_path)
          expect(user_authenticated_session.reload).not_to be_active
          expect(admin_authenticated_session.reload).to be_active
          expect(session).not_to have_key(AuthenticatedSessions::Registry.session_key(:user))
          expect(session[AuthenticatedSessions::Registry.session_key(:admin_user)]).
            to eq(admin_authenticated_session.identifier)
        end
      end
    end
  end
end
