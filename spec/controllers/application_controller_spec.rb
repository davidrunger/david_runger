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
end
