# frozen_string_literal: true

RSpec.describe Api::UsersController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#update' do
    subject(:patch_update) { patch(:update, params: params) }

    context 'when a user is updating themself' do
      let(:user_id_param) { user.id }

      context 'when the params are valid' do
        let(:valid_params) { { id: user_id_param, user: { phone: '123-555-4321' } } }
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

    context 'when a user attempts to update another user' do
      let(:user_id_param) { other_user.id }
      let(:other_user) { User.where.not(id: user).first! }

      context 'when the params are valid' do
        let(:valid_params) { { id: user_id_param, user: { phone: '123-555-4321' } } }
        let(:params) { valid_params }

        it 'returns a 403 status code' do
          patch_update
          expect(response.status).to eq(403)
        end

        it 'does not update the user' do
          expect { patch_update }.not_to change { user.reload.phone }
        end

        it 'responds with a JSON error message' do
          patch_update

          expect(response.parsed_body).to eq('error' => 'You are not authorized.')
        end
      end
    end
  end
end
