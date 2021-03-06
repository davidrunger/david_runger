# frozen_string_literal: true

RSpec.describe SessionsController do
  describe '#new' do
    subject(:get_new) { get(:new) }

    context 'when a user is already signed in' do
      before { sign_in(user) }

      let(:user) { users(:user) }

      it 'redirects to the root path with a flash message' do
        get_new

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('You are already logged in.')
      end
    end

    context 'when a user is not signed in' do
      before { sign_out(:user) }

      it 'renders the new session page' do
        get_new
        expect(response.body).to have_css('button.google-login')
      end
    end
  end

  describe '#url_base' do
    subject(:url_base) { controller.send(:url_base) }

    context 'when Rails.env is "development"', rails_env: :development do
      it 'returns a URL including the port number' do
        expect(url_base).to eq('http://test.host:80')
      end
    end

    context 'when Rails.env is "production"', rails_env: :production do
      it 'returns a URL that does not include a port number' do
        expect(url_base).to eq('https://test.host')
      end
    end
  end
end
