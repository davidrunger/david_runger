# frozen_string_literal: true

RSpec.describe Admin::UsersController do
  before { sign_in(admin_user) }

  let(:admin_user) { users(:admin) }
  let(:user) { User.where.not(id: admin_user).first! }

  describe '#update' do
    subject(:patch_update) { patch(:update, params: { id: user.id, user: user_params }) }

    context 'when user has a phone number' do
      before { expect(user.phone).to be_present }

      context 'when submitting a phone of "" (blank string)' do
        let(:user_params) { { phone: '' } }

        it "changes the user's phone to `nil`" do
          expect { patch_update }.
            to change { user.reload.phone }.
            from(String).
            to(nil)
        end
      end
    end
  end
end
