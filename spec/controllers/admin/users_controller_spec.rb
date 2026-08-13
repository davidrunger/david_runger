RSpec.describe Admin::UsersController do
  let(:user) { users(:user) }
  let(:admin_user) { admin_users(:admin_user) }
  let(:admin_authenticated_session) { admin_user.authenticated_sessions.first! }

  context 'when logged in as an AdminUser' do
    before do
      sign_in(admin_user)
      session[AuthenticatedSessions::Registry.session_key(:admin_user)] =
        admin_authenticated_session.identifier
    end

    describe '#index' do
      subject(:get_index) { get(:index) }

      it 'responds with 200' do
        get_index
        expect(response).to have_http_status(200)
      end
    end

    describe '#show' do
      subject(:get_show) { get(:show, params: { id: user.id }) }

      it 'responds with 200' do
        get_show
        expect(response).to have_http_status(200)
      end
    end

    describe '#edit' do
      subject(:get_edit) { get(:edit, params: { id: user.id }) }

      it 'responds with 200' do
        get_edit
        expect(response).to have_http_status(200)
      end
    end

    describe '#unbecome' do
      subject(:delete_unbecome) { delete(:unbecome, params: { id: user.id }) }

      context 'when a user is signed in' do
        before do
          impersonation = create(
            :authenticated_session,
            authenticatable: user,
            authentication_kind: 'admin_impersonation',
            initiated_by_authenticated_session: admin_authenticated_session,
          )
          sign_in(user)
          session[AuthenticatedSessions::Registry.session_key(:user)] = impersonation.identifier
        end

        it 'revokes the impersonation and redirects to the admin user show page' do
          delete_unbecome

          expect(user.authenticated_sessions.last!.reload).not_to be_active
          expect(admin_authenticated_session.reload).to be_active
          expect(response).to redirect_to(admin_user_path(user))
        end
      end

      # this can happen if an AdminUser double clicks the "Unbecome" link, for example
      context 'when a user is not signed in' do
        before { sign_out(:user) }

        it 'redirects to the admin user show page' do
          delete_unbecome
          expect(response).to redirect_to(admin_user_path(user))
        end
      end
    end

    describe '#destroy' do
      subject(:delete_destroy) { delete(:destroy, params: { id: user.id }) }

      it 'redirects to the users index page' do
        delete_destroy

        expect(response).to redirect_to(admin_users_path)
      end
    end
  end

  describe '#become' do
    subject(:post_become) { post(:become, params: { id: user.id }) }

    context 'when logged in as an AdminUser' do
      before do
        sign_in(admin_user)
        session[AuthenticatedSessions::Registry.session_key(:admin_user)] =
          admin_authenticated_session.identifier
      end

      it 'creates a linked impersonation and redirects to the groceries app' do
        post_become

        impersonation = user.authenticated_sessions.last!
        expect(impersonation.authentication_kind).to eq('admin_impersonation')
        expect(impersonation.initiated_by_authenticated_session).to eq(admin_authenticated_session)
        expect(response).to redirect_to(groceries_path)
      end
    end

    context 'when already signed in as the selected User' do
      let(:user_authenticated_session) { user.authenticated_sessions.first! }

      before do
        sign_in(admin_user)
        session[AuthenticatedSessions::Registry.session_key(:admin_user)] =
          admin_authenticated_session.identifier
        sign_in(user)
        session[AuthenticatedSessions::Registry.session_key(:user)] =
          user_authenticated_session.identifier
      end

      it 'replaces the User session with the new impersonation session' do
        post_become

        impersonation = user.authenticated_sessions.last!
        expect(impersonation.authentication_kind).to eq('admin_impersonation')
        expect(impersonation).to be_active
        expect(session[AuthenticatedSessions::Registry.session_key(:user)]).
          to eq(impersonation.identifier)
        expect(response).to redirect_to(groceries_path)
      end
    end

    context 'when not logged in as an AdminUser (just a User)' do
      before do
        controller.sign_out_all_scopes
        sign_in(users(:user))
      end

      it 'redirects to the admin login page' do
        post_become
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
