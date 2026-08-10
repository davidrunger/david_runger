RSpec.describe 'Logging in as an AdminUser via Google auth' do
  before do
    MockOmniAuth.google_oauth2(email: stubbed_admin_user_email, sub: mocked_google_response_sub)
  end

  let(:mocked_google_response_sub) { "1#{rand(100_000_000_000_000_000)}" }

  context 'when an AdminUser with the email exists in the database' do
    let(:stubbed_admin_user_email) { admin_user.email }
    let(:admin_user) { admin_users(:admin_user) }

    context 'when the AdminUser does not have a google_sub in the database' do
      before { expect(admin_user.google_sub).to eq(nil) }

      it "allows the AdminUser to log in and saves the AdminUser's Google 'sub' value" do
        visit(new_admin_user_session_path)

        expect(page).to have_css('google-sign-in-button')

        expect {
          click_sign_in_with_google
          expect(page).to have_current_path(admin_root_path)
        }.not_to change { AdminUser.count }

        expect(page).to have_text('David Runger Admin Dashboard')
        expect(page).to have_text('Admin Tools')
        expect(admin_user.reload.google_sub).to eq(mocked_google_response_sub)
      end
    end

    context 'when the AdminUser has a google_sub in the database' do
      before { admin_user.update!(google_sub: admin_user_google_sub.presence!) }

      let(:admin_user_google_sub) { "1#{rand(100_000_000_000_000_000)}" }

      context 'when the sub returned from Google matches the google_sub in our database' do
        let(:mocked_google_response_sub) { admin_user_google_sub }

        it 'allows the AdminUser to log in via Google' do
          visit(new_admin_user_session_path)
          expect(page).to have_css('google-sign-in-button')

          expect { click_sign_in_with_google }.not_to change { AdminUser.count }

          expect(page).to have_current_path(admin_root_path)
          expect(page).to have_text('David Runger Admin Dashboard')
          expect(page).to have_text('Admin Tools')
        end
      end

      context 'when the sub returned from Google does not match the google_sub in our database' do
        let(:mocked_google_response_sub) { (Integer(admin_user_google_sub) + 1).to_s }

        it 'redirects with an error message, does not sign in the AdminUser, and reports the error' do
          allow(Rails.error).to receive(:report).and_call_original

          visit(new_admin_user_session_path)
          expect(page).to have_css('google-sign-in-button')

          expect { click_sign_in_with_google }.not_to change { AdminUser.count }

          expect(page).to have_current_path(new_admin_user_session_path)
          expect(page).to have_flash_message(<<~FLASH.squish, type: :alert)
            You are attempting a domain identity takeover attack. Blocked!
          FLASH

          expect(Rails.error).to have_received(:report).
            with(
              Admin::OmniauthCallbacksController::SubMismatch,
              context: {
                email: admin_user.email,
                admin_user_sub_in_db: admin_user.google_sub,
                sub_in_google_response: mocked_google_response_sub,
              },
            )

          visit(admin_root_path)
          expect(page).to have_current_path(new_admin_user_session_path)
        end
      end
    end
  end

  context 'when there is no AdminUser in the database with the email' do
    let(:stubbed_admin_user_email) { "#{SecureRandom.uuid}@gmail.com" }

    before { expect(AdminUser.where(email: stubbed_admin_user_email)).not_to exist }

    it 'does not create an AdminUser' do
      visit(new_admin_user_session_path)
      expect(page).to have_css('google-sign-in-button')

      expect { click_sign_in_with_google }.not_to change { AdminUser.count }
      expect(AdminUser.find_by(email: stubbed_admin_user_email)).to eq(nil)

      expect(page).to have_flash_message(
        "#{stubbed_admin_user_email} is not authorized to access admin",
        type: :alert,
      )
      expect(page).to have_current_path('/admin/login')
    end
  end
end
