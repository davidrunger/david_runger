# frozen_string_literal: true

RSpec.describe Devise::SessionsController do
  describe '#destroy' do
    subject(:delete_destroy) { delete(:destroy) }

    before { request.env['devise.mapping'] = Devise.mappings[:user] }

    context 'when a user is signed in' do
      before { sign_in(user) }

      let(:user) { users(:user) }

      context 'when the request format is json', request_format: :json do
        it 'responds with 204' do
          delete_destroy
          expect(response.status).to eq(204)
        end
      end
    end
  end
end
