# frozen_string_literal: true

RSpec.describe ApplicationController do
  controller do
    def index
      render(plain: 'This is the #index action.')
    end
  end

  let(:user) { users(:user) }

  describe '#store_redirect_location' do
    subject(:get_index) { get(:index, params: params) }

    context 'when a user is logged in' do
      before { sign_in(user) }

      context 'when a request is made with a redirect_to param' do
        let(:redirect_to_path) { '/runger' }
        let(:params) { { redirect_to: redirect_to_path } }

        it "stores the value of the redirect_to param in the user's session" do
          expect { get_index }.to change { session['redirect_to'] }.from(nil).to(redirect_to_path)
        end
      end
    end
  end
end
