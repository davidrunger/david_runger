RSpec.describe MyAccountController do
  let(:user) { users(:user) }

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
end
