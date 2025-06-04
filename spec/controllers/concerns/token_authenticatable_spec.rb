RSpec.describe TokenAuthenticatable, :without_verifying_authorization do
  controller(ApplicationController) do
    def index
      render(plain: 'action:index')
    end
  end

  subject(:request_index) { public_send(http_method, :index, params:) }

  let(:auth_token) { AuthToken.first! }
  let(:http_method) { :post }
  let(:headers) { {} }
  let(:params) { {} }
  let(:authorization_header_name) { 'Authorization' }
  let(:auth_token_param_name) { 'auth_token' }

  before do
    request.headers.merge!(headers)
  end

  describe '#current_or_auth_token_user' do
    context 'when no user is logged in' do
      before { sign_out(:user) }

      context 'when no auth_token header or param is provided' do
        before do
          expect(headers.transform_keys(&:to_s)[authorization_header_name]).to be_blank
          expect(params.transform_keys(&:to_s)[auth_token_param_name]).to be_blank
        end

        it 'is nil' do
          request_index

          expect(controller.send(:current_or_auth_token_user)).to eq(nil)
        end
      end

      context 'when an auth_token param corresponding to an AuthToken secret is provided' do
        let(:params) { { auth_token_param_name => auth_token.secret } }

        context 'when the AuthToken has a blank permitted_actions_list' do
          before { auth_token.update!(permitted_actions_list: nil) }

          context 'when the auth_token is provided via a query param' do
            # For GET, Rails will provide the `params` as query params.
            let(:http_method) { :get }

            it 'is nil' do
              request_index

              expect(controller.send(:current_or_auth_token_user)).to eq(nil)
            end
          end

          context 'when the auth_token is provided via a body param' do
            # For POST, Rails will provide the `params` as body params.
            let(:http_method) { :post }

            it "is the AuthToken's user" do
              request_index

              expect(controller.send(:current_or_auth_token_user)).to eq(auth_token.user)
            end
          end
        end

        context 'when the AuthToken has a permitted_actions_list that includes the requested action' do
          before do
            auth_token.update!(permitted_actions_list: 'anonymous#index, api/csp_results#create')
          end

          it "is the AuthToken's user" do
            request_index

            expect(controller.send(:current_or_auth_token_user)).to eq(auth_token.user)
          end
        end

        context 'when the AuthToken has a permitted_actions_list that does not include the requested action' do
          before do
            auth_token.update!(permitted_actions_list: 'anonymous#show, api/csp_results#create')
          end

          it 'is nil' do
            request_index

            expect(controller.send(:current_or_auth_token_user)).to eq(nil)
          end
        end
      end

      context 'when an Authorization header corresponding to an AuthToken secret is provided' do
        let(:headers) { { authorization_header_name => "Bearer #{auth_token.secret}" } }

        context 'when the AuthToken has a blank permitted_actions_list' do
          before { auth_token.update!(permitted_actions_list: nil) }

          it "is the AuthToken's user" do
            request_index

            expect(controller.send(:current_or_auth_token_user)).to eq(auth_token.user)
          end
        end

        context 'when the AuthToken has a permitted_actions_list that includes the requested action' do
          before do
            auth_token.update!(permitted_actions_list: 'anonymous#index, api/csp_results#create')
          end

          it "is the AuthToken's user" do
            request_index

            expect(controller.send(:current_or_auth_token_user)).to eq(auth_token.user)
          end
        end

        context 'when the AuthToken has a permitted_actions_list that does not include the requested action' do
          before do
            auth_token.update!(permitted_actions_list: 'anonymous#show, api/csp_results#create')
          end

          it 'is nil' do
            request_index

            expect(controller.send(:current_or_auth_token_user)).to eq(nil)
          end
        end
      end
    end
  end

  describe '#verify_valid_auth_token!' do
    subject(:verify_valid_auth_token!) { controller.send(:verify_valid_auth_token!) }

    context 'when the secret in an Authorization header is not for any token' do
      let(:headers) { { authorization_header_name => "Bearer #{SecureRandom.uuid}" } }

      it 'raises a TokenAuthenticatable::InvalidToken error' do
        request_index

        expect { verify_valid_auth_token! }.to raise_error(TokenAuthenticatable::InvalidToken)
      end
    end

    context 'when the secret for an AuthToken is provided in an Authorization header' do
      let(:headers) { { authorization_header_name => "Bearer #{auth_token.secret}" } }

      context 'when the AuthToken does not have any restrictions on permitted controller actions' do
        before { auth_token.update!(permitted_actions_list: nil) }

        it 'returns nil' do
          request_index

          expect(verify_valid_auth_token!).to eq(nil)
        end
      end

      context 'when the AuthToken has restrictions on permitted controller actions' do
        context 'when the request is for a permitted action' do
          before { auth_token.update!(permitted_actions_list: 'anonymous#index') }

          it 'returns nil' do
            request_index

            expect(verify_valid_auth_token!).to eq(nil)
          end
        end

        context 'when the request is for an action that is not permitted' do
          before { auth_token.update!(permitted_actions_list: 'anonymous#show') }

          it 'raises a TokenAuthenticatable::UnauthorizedAction error' do
            request_index

            expect { verify_valid_auth_token! }.
              to raise_error(TokenAuthenticatable::UnauthorizedAction)
          end
        end
      end
    end
  end
end
