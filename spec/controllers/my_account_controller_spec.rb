RSpec.describe MyAccountController do
  let(:user) { users(:user) }
  let(:admin_user) { admin_users(:admin_user) }

  describe '#destroy' do
    subject(:delete_destroy) { delete(:destroy) }

    let(:user_to_destroy) { users(:user) }

    context 'when not logged in' do
      before { Devise.sign_out_all_scopes }

      it 'does not delete the specified user' do
        delete_destroy

        expect { user.reload }.not_to raise_error
      end
    end

    context 'when logged in' do
      before { sign_in(logged_in_user) }

      context 'when requesting deletion of another user' do
        let(:logged_in_user) { User.excluding(user_to_destroy).first! }

        it 'does not delete the specified user' do
          delete_destroy

          expect { user_to_destroy.reload }.not_to raise_error
        end
      end

      context "when requesting deletion of one's own account" do
        let(:logged_in_user) { user_to_destroy }

        it 'deletes the user and redirects to the homepage with a flash message' do
          delete_destroy

          expect { user_to_destroy.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq('We have deleted your account.')
        end
      end
    end
  end

  describe '#edit' do
    subject(:get_edit) { get(:edit) }

    context 'when signed in' do
      before { sign_in(user) }

      it 'renders a form to create a new auth token' do
        get_edit

        expect(response.body).to have_button('Create New Auth Token')
      end
    end
  end

  describe '#show' do
    subject(:get_show) { get(:show) }

    before { sign_in(user) }

    it "lists only the current account's unrevoked, non-impersonation sessions" do
      visible_session = user.authenticated_sessions.first!
      create(:authenticated_session, authenticatable: User.excluding(user).first!)
      create(:authenticated_session, authenticatable: user, revoked_at: Time.current)
      impersonation = create(
        :authenticated_session,
        authenticatable: user,
        authentication_kind: 'admin_impersonation',
        initiated_by_authenticated_session: admin_user.authenticated_sessions.first!,
      )

      get_show

      expect(assigns(:authenticated_sessions).map(&:object)).to include(visible_session)
      expect(assigns(:authenticated_sessions).map(&:object)).to all(
        satisfy { |record| record.authenticatable == user && record.active? },
      )
      expect(response.body).to have_text(visible_session.initial_ip)
      expect(response.body).to have_text(visible_session.location)
      expect(response.body).to have_text(visible_session.isp)
      expect(response.body).not_to have_text(visible_session.identifier)
      expect(response.body).not_to have_text(impersonation.initial_ip)
      expect(response.body).to match(/Last active:.*\d{1,2}:\d{2} [AP]M/m)
    end
  end
end
