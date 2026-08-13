RSpec.describe AuthenticatedSessionsController do
  let(:user) { users(:user) }
  let(:other_user) { User.excluding(user).first! }
  let(:admin_user) { admin_users(:admin_user) }
  let(:current_authenticated_session) { user.authenticated_sessions.first! }

  before do
    sign_in(user)
    session[AuthenticatedSessions::Registry.session_key(:user)] =
      current_authenticated_session.identifier
  end

  describe '#revoke' do
    subject(:patch_revoke) { patch(:revoke, params: { id: authenticated_session.id }) }

    context 'with another session belonging to the current user' do
      let(:authenticated_session) { create(:authenticated_session, authenticatable: user) }

      it 'revokes only that session and leaves the current session signed in' do
        patch_revoke

        expect(authenticated_session.reload).not_to be_active
        expect(current_authenticated_session.reload).to be_active
        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to(my_account_path)
      end
    end

    context 'with the current session' do
      let(:authenticated_session) { current_authenticated_session }

      it 'revokes the session and signs the User scope out' do
        patch_revoke

        expect(authenticated_session.reload).not_to be_active
        expect(controller.current_user).to eq(nil)
        expect(response).to redirect_to(root_path)
      end
    end

    context "with another user's session" do
      let(:authenticated_session) { create(:authenticated_session, authenticatable: other_user) }

      it 'prevents cross-account revocation' do
        expect { patch_revoke }.to raise_error(ActiveRecord::RecordNotFound)
        expect(authenticated_session.reload).to be_active
      end
    end

    context 'with an impersonation session' do
      let(:parent) { admin_user.authenticated_sessions.first! }
      let(:authenticated_session) do
        create(
          :authenticated_session,
          authenticatable: user,
          authentication_kind: 'admin_impersonation',
          initiated_by_authenticated_session: parent,
        )
      end

      it 'does not let a User revoke the hidden session' do
        expect { patch_revoke }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
