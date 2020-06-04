# frozen_string_literal: true

RSpec.describe Api::UsersController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#update' do
    subject(:patch_update) { patch(:update, params: params) }

    context 'when the params are valid' do
      let(:valid_params) { { id: user.id, user: { phone: '123-555-4321' } } }
      let(:params) { valid_params }

      it 'returns a 200 status code' do
        patch_update
        expect(response.status).to eq(200)
      end

      it 'updates the user' do
        expect { patch_update }.
          to change { user.reload.phone }.
          to("1#{params.dig(:user, :phone).delete('-')}")
      end

      it 'responds with the user as JSON' do
        patch_update
        user.reload

        expect(response.parsed_body).to include(
          'email' => user.email,
          'id' => user.id,
          'phone' => user.phone,
        )
      end
    end
  end
end
