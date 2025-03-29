RSpec.describe 'Logging in as a User via Google auth', :prerendering_disabled do
  context 'when OmniAuth test mode is enabled and OmniAuth is mocked' do
    before do
      expect(OmniAuth.config.test_mode).to eq(true)
      MockOmniAuth.google_oauth2(email: stubbed_user_email, sub: mocked_google_response_sub)
    end

    let(:mocked_google_response_sub) { "1#{rand(100_000_000_000_000_000)}" }

    context 'when the user already exists in the database' do
      let(:stubbed_user_email) { user.email }
      let(:user) { users(:user) }

      context 'when the user does not have a google_sub in the database' do
        before { expect(user.google_sub).to eq(nil) }

        it 'allows the user to log in with Google' do
          visit(new_user_session_path)
          expect(page).to have_css('google-sign-in-button')

          expect { click_sign_in_with_google }.not_to change { User.count }

          expect(page).to have_current_path(root_path)
          expect(page).to have_text('David Runger Full stack web developer')

          expect(sign_in_confirmed_via_my_account?(user)).to eq(true)
        end
      end

      context 'when the user has a google_sub in the database' do
        context 'when the sub returned from Google matches the google_sub in our database' do
          before { user.update!(google_sub: mocked_google_response_sub) }

          context 'when no User is logged in' do
            before { sign_out(:user) }

            context 'when the user attempts to access a page that requires authentication' do
              it 'redirects to the login page, allows the user to log in with Google, and redirects back to their initially requested page' do
                visit(my_account_path)

                expect(page).to have_current_path(new_user_session_path)
                expect(page).to have_css('google-sign-in-button')

                expect { click_sign_in_with_google }.not_to change { User.count }

                expect(page).to have_current_path(my_account_path)
                expect(page).to have_text(user.email)
              end
            end
          end

          context 'when no User or AdminUser is logged in' do
            before { Devise.sign_out_all_scopes }

            context 'when there is an AdminUser and a User with the same stubbed_user_email' do
              before { AdminUser.find_or_create_by!(email: user.email) }

              context 'when the AdminUser has logged in' do
                before do
                  visit(new_admin_user_session_path)

                  expect(page).to have_current_path(new_admin_user_session_path)

                  click_sign_in_with_google

                  expect(page).to have_text('David Runger Admin Dashboard')
                end

                context 'when the user tries to go to the My Account page' do
                  it 'redirects the user to log in and, after successful login, redirects to the My Account page' do
                    visit(my_account_path)

                    expect(page).to have_current_path(new_user_session_path)

                    click_sign_in_with_google

                    expect(page).to have_current_path(my_account_path)
                    expect(page).to have_text('My Account')
                  end
                end
              end
            end
          end
        end

        context 'when the sub returned from Google does not match the google_sub in our database' do
          before { user.update!(google_sub: (Integer(mocked_google_response_sub) + 1).to_s) }

          it 'redirects with an error message, does not sign in the user, and sends a report to Rollbar' do
            allow(Rails.error).to receive(:report).and_call_original

            visit(new_user_session_path)
            expect(page).to have_css('google-sign-in-button')

            expect { click_sign_in_with_google }.not_to change { User.count }

            expect(page).to have_current_path(new_user_session_path)
            expect(page).to have_flash_message(<<~FLASH.squish, type: :alert)
              You are attempting a domain identity takeover attack. Blocked!
            FLASH

            expect(Rails.error).to have_received(:report).
              with(
                Users::OmniauthCallbacksController::SubMismatch,
                context: {
                  user_sub_in_db: user.google_sub,
                  sub_in_google_response: mocked_google_response_sub,
                },
              )

            visit(my_account_path)
            expect(page).to have_current_path(new_user_session_path)
            expect(page).to have_flash_message(<<~FLASH.squish, type: :alert)
              You must sign in first.
            FLASH
          end
        end
      end
    end

    context 'when there is no user in the database with the email' do
      let(:stubbed_user_email) { "#{SecureRandom.uuid}@gmail.com" }

      before { expect(User.where(email: stubbed_user_email)).not_to exist }

      it "allows a user to sign up (and log in) with Google and saves the user's Google 'sub' value" do
        visit(new_user_session_path)
        expect(page).to have_css('google-sign-in-button')

        expect { click_sign_in_with_google }.to change { User.count }.by(1)
        user = User.find_by!(email: stubbed_user_email)

        expect(sign_in_confirmed_via_my_account?(user)).to eq(true)
        expect(user.google_sub).to eq(mocked_google_response_sub)
      end
    end
  end

  context 'when OmniAuth test mode is disabled', :permit_all_external_requests do
    around do |spec|
      original_omni_auth_test_mode = OmniAuth.config.test_mode
      OmniAuth.config.test_mode = false

      spec.run
    ensure
      OmniAuth.config.test_mode = original_omni_auth_test_mode
    end

    context 'when Google responds with "This is Google OAuth."' do
      let(:google_response_content) { 'This is Google OAuth.' }

      before do
        browser = page.driver.browser
        browser.network.intercept
        browser.on(:request) do |request|
          if request.match?(%r{\Ahttps://accounts.google.com/o/oauth2/auth\?})
            request.respond(body: google_response_content)
          else
            request.continue
          end
        end
      end

      it "renders Google's response" do
        visit(new_user_session_path)
        expect(page).to have_css('google-sign-in-button')

        click_sign_in_with_google

        expect(page).to have_text(google_response_content)
      end
    end
  end
end
