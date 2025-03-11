RSpec.describe Admin::UsersController do
  let(:user) { users(:user) }

  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user)) }

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
      subject(:get_unbecome) { get(:unbecome, params: { id: user.id }) }

      context 'when a user is signed in' do
        before { sign_in(user) }

        it 'redirects to the admin user show page' do
          get_unbecome
          expect(response).to redirect_to(admin_user_path(user))
        end
      end

      # this can happen if an AdminUser double clicks the "Unbecome" link, for example
      context 'when a user is not signed in' do
        before { sign_out(:user) }

        it 'redirects to the admin user show page' do
          get_unbecome
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
    subject(:get_become) { get(:become, params: { id: user.id }) }

    context 'when logged in as an AdminUser' do
      before { sign_in(admin_users(:admin_user)) }

      it 'redirects to the groceries app' do
        get_become
        expect(response).to redirect_to(groceries_path)
      end
    end

    context 'when not logged in as an AdminUser (just a User)' do
      before do
        controller.sign_out_all_scopes
        sign_in(users(:user))
      end

      it 'redirects to the admin login page' do
        get_become
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
