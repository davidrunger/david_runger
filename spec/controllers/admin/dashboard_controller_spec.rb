RSpec.describe Admin::DashboardController do
  let(:admin_user) { admin_users(:admin_user) }

  describe '#index' do
    subject(:get_index) { get(:index) }

    context 'when logged in as an AdminUser' do
      before { sign_in(admin_user) }

      it 'responds with 200' do
        get_index
        expect(response).to have_http_status(200)
      end
    end

    context 'when logged in as a user but not logged in as an AdminUser' do
      before do
        controller.sign_out_all_scopes
        sign_in(users(:user))
      end

      it 'redirects to the admin login page with a flash message' do
        get_index
        expect(response.status).to redirect_to(new_admin_user_session_path)
        expect(flash[:alert]).to eq('You must sign in as an admin user first.')
      end
    end
  end
end
