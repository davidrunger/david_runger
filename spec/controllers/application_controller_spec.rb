# frozen_string_literal: true

RSpec.describe ApplicationController, :without_verifying_authorization do
  controller do
    def index
      render(plain: 'This is the #index action.')
    end
  end

  describe '#current_admin_user' do
    subject(:current_admin_user) { controller.send(:current_admin_user) }

    context 'when Rails.env is "development"' do
      before do
        expect(Rails).
          to receive(:env).
          and_return(ActiveSupport::EnvironmentInquirer.new('development'))
      end

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
end
