RSpec.describe WorkoutsController do
  let(:user) { users(:user) }

  describe '#index' do
    subject(:get_index) { get(:index) }

    context 'when logged in' do
      before { sign_in(user) }

      it 'responds with 200' do
        get_index

        expect(response).to have_http_status(200)
      end

      it 'has a title including "Workout"' do
        get_index

        expect(response.body).to have_title(/\AWorkout - David Runger\z/)
      end
    end

    context 'when not logged in' do
      before { controller.sign_out_all_scopes }

      it 'redirects to the login page' do
        get_index

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
