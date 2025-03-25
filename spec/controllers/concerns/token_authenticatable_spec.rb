RSpec.describe TokenAuthenticatable, :without_verifying_authorization do
  controller(ApplicationController) do
    def index
      render(plain: '#index action')
    end
  end

  let(:auth_token) { AuthToken.first! }

  describe '#current_or_auth_token_user' do
    before do
      request.headers.merge!(headers)
      get(:index, params:)
    end

    let(:headers) { {} }
    let(:params) { {} }

    context 'when no user is logged in' do
      before { sign_out(:user) }

      context 'when no auth_token header or param is provided' do
        before do
          expect(headers).to be_blank
          expect(params).to be_blank
        end

        it 'is nil' do
          expect(controller.send(:current_or_auth_token_user)).to eq(nil)
        end
      end

      context 'when an auth_token param corresponding to an AuthToken secret is provided' do
        let(:params) { { auth_token: auth_token.secret } }

        it "is the AuthToken's user" do
          expect(controller.send(:current_or_auth_token_user)).to eq(auth_token.user)
        end
      end

      context 'when an Authorization header corresponding to an AuthToken secret is provided' do
        let(:headers) { { 'Authorization' => "Bearer #{auth_token.secret}" } }

        it "is the AuthToken's user" do
          expect(controller.send(:current_or_auth_token_user)).to eq(auth_token.user)
        end
      end
    end
  end
end
