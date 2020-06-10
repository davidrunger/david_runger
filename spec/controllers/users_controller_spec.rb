# frozen_string_literal: true

RSpec.describe UsersController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#edit' do
    subject(:get_edit) { get(:edit, params: { id: user.id }) }

    it "renders a form to update the user's phone number" do
      get_edit

      expect(response.body).to have_css('form')
      expect(response.body).to have_text('Phone')
      expect(response.body).to have_css('input[type="submit"][value="Update User"]')
    end
  end

  describe '#update' do
    subject(:patch_update) { patch(:update, params: { id: user.id, user: user_params }) }

    context "when updating the user's phone number" do
      let(:user_params) { { phone: new_phone_number } }

      before { user.update!(phone: '11231231234') }

      context 'when the user is valid (i.e. can be updated successfully)' do
        before { expect(user).to be_valid }

        context 'when the submitted params are valid' do
          let(:new_phone_number) { "1555#{Array.new(7) { rand(10).to_s }.join('')}" }

          it 'updates the user' do
            expect { patch_update }.
              to change { user.reload.phone }.
              to(new_phone_number)
          end

          it 'sets a flash message' do
            patch_update

            expect(flash[:notice]).to eq('Updated successfully!')
          end
        end

        context 'when the submitted params are not valid' do
          let(:new_phone_number) { 'this is not a phone number' }

          it 'does not update the user' do
            expect { patch_update }.not_to change { user.reload.phone }
          end

          it 're-renders the edit page' do
            patch_update

            expect(patch_update).to render_template('users/edit')
          end

          it 'sets a flash message' do
            patch_update

            expect(flash[:alert]).to eq('Please fix these problems: Phone is invalid')
          end
        end
      end
    end

    context 'when params include an `auth_token`' do
      let(:user_params) { { auth_token: new_auth_token } }
      let(:new_auth_token) { SecureRandom.uuid }

      it "updates the user's `auth_token` to the new value" do
        expect { patch_update }.to change { user.reload.auth_token }.to(new_auth_token)
      end
    end
  end
end
