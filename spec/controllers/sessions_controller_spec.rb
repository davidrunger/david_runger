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

        expect(response.body).to have_css('google-sign-in-button')
      end
    end
  end

  describe '#url_base' do
    subject(:url_base) { controller.send(:url_base) }

    before { expect(controller.request).to receive(:port).and_return(port) }

    context 'when the port is 80' do
      let(:port) { 80 }

      it 'returns a URL that does not include a port number' do
        expect(url_base).to eq('http://test.host')
      end
    end

    context 'when the port is 443' do
      let(:port) { 443 }

      it 'returns a URL that does not include a port number' do
        expect(url_base).to eq('http://test.host')
      end
    end

    context 'when the port is not 80 or 443' do
      let(:port) { 3000 }

      it 'returns a URL including the port number' do
        expect(url_base).to eq("http://test.host:#{port}")
      end
    end
  end
end
