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
        expect(response.body).to have_css('button.google-login')
      end
    end
  end

  describe '#url_base' do
    subject(:url_base) { controller.send(:url_base) }

    before do
      expect(Rails).
        to receive(:env).
        and_return(ActiveSupport::EnvironmentInquirer.new(rails_env))
    end

    context 'when Rails.env is "development"' do
      let(:rails_env) { 'development' }

      it 'returns a URL including the port number' do
        expect(url_base).to eq('http://test.host:80')
      end
    end

    context 'when Rails.env is "production"' do
      let(:rails_env) { 'production' }

      it 'returns a URL that does not include a port number' do
        expect(url_base).to eq('https://test.host')
      end
    end
  end
end
