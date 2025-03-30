RSpec.describe ApplicationController, :without_verifying_authorization do
  controller do
    def index
      render(plain: 'This is the #index action.')
    end
  end

  describe '#current_user' do
    subject(:current_user) { controller.send(:current_user) }

    context 'when Rails.env is "development"', rails_env: :development do
      context 'when the `automatic_user_login` flag is enabled' do
        before { activate_feature!(:automatic_user_login) }

        context 'when no User is logged in' do
          before { controller.sign_out_all_scopes }

          context 'when there is a user with email "davidjrunger@gmail.com"' do
            before { User.find_or_create_by!(email: david_runger_email) }

            let(:david_runger_email) { 'davidjrunger@gmail.com' }

            it 'returns the User with email "davidjrunger@gmail.com"' do
              expect(current_user.email).to eq(david_runger_email)
            end
          end
        end
      end
    end
  end

  describe '#current_admin_user' do
    subject(:current_admin_user) { controller.send(:current_admin_user) }

    context 'when Rails.env is "development"', rails_env: :development do
      context 'when the `automatic_admin_login` flag is enabled' do
        before { activate_feature!(:automatic_admin_login) }

        context 'when no AdminUser is logged in' do
          before { controller.sign_out_all_scopes }

          it 'returns the AdminUser with email "davidjrunger@gmail.com"' do
            expect(current_admin_user.email).to eq('davidjrunger@gmail.com')
          end
        end
      end
    end
  end

  describe '#first_redirect_chain_value_to_follow' do
    subject(:first_redirect_chain_value_to_follow) do
      controller.send(:first_redirect_chain_value_to_follow, redirect_chain)
    end

    context 'when the redirect chain is 20 (or more) unrecognized wizard steps long' do
      let(:redirect_chain) { ['wizard:some-wizard-step'] * 20 }

      it 'returns nil' do
        expect(first_redirect_chain_value_to_follow).to eq(nil)
      end
    end
  end

  describe 'response for authorization errors' do
    context 'when making a JSON request with an auth token secret' do
      subject(:post_index) do
        post(
          :index,
          params: { auth_token: auth_token_secret },
          format: :json,
        )
      end

      context 'when the secret is not valid for any AuthToken' do
        let(:auth_token_secret) { SecureRandom.uuid }

        it 'responds with "Your token is not valid."' do
          post_index

          expect(response.parsed_body).to eq('error' => 'Your token is not valid.')
        end
      end

      context 'when the secret is valid for an AuthToken but the AuthToken is not permitted for the action' do
        before do
          auth_token.update!(permitted_actions_list: 'anonymous#create')
        end

        let(:auth_token_secret) { auth_token.secret }
        let(:auth_token) { AuthToken.first! }

        it 'responds with "Your token is not valid for <action>."' do
          post_index

          expect(response.parsed_body).
            to eq('error' => 'Your token is not permitted for anonymous#index.')
        end
      end
    end
  end
end
