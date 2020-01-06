# frozen_string_literal: true

RSpec.describe SessionsController do
  describe '#new' do
    subject(:get_new) { get(:new) }

    context 'when a user is already signed in' do
      before { sign_in(user) }

      let(:user) { users(:user) }

      it 'redirects to the root path' do
        get_new
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when a user is not signed in' do
      before { sign_out(:user) }

      it 'renders the new session page' do
        get_new
        expect(response.body).to have_css('input[type="submit"][value="Sign in with Google"]')
      end
    end
  end
end
