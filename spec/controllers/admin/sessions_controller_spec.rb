# frozen_string_literal: true

RSpec.describe Admin::SessionsController do
  describe '#new' do
    subject(:get_new) { get(:new) }

    context 'when an AdminUser is already signed in' do
      before { sign_in(admin_user) }

      let(:admin_user) { admin_users(:admin_user) }

      it 'redirects to the Admin root path with a flash message' do
        get_new

        expect(response).to redirect_to(admin_root_path)
        expect(flash[:notice]).to eq('You are already logged in.')
      end
    end
  end
end
