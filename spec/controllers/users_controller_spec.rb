# frozen_string_literal: true

RSpec.describe UsersController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#update' do
    subject(:patch_update_user) { patch(:update, params: { id: user.id, user: user_params }) }

    let(:new_phone_number) { "1555#{rand(10_000_000)}" }
    let(:user_params) { { phone: new_phone_number } }

    before { user.update!(phone: '11231231234') }

    context 'when the user is valid (i.e. can be updated successfully)' do
      before { expect(user).to be_valid }

      it 'updates the user' do
        expect { patch_update_user }.
          to change { user.reload.phone }.
          to(new_phone_number)
      end

      it 'sets a flash message' do
        patch_update_user

        expect(flash[:notice]).to eq('Updated successfully!')
      end
    end
  end
end
