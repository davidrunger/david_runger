RSpec.describe 'Logging in as a User via Google auth', :prerendering_disabled do
  context 'when OmniAuth test mode is enabled and OmniAuth is mocked' do
    before do
      expect(OmniAuth.config.test_mode).to eq(true)
      MockOmniAuth.google_oauth2(email: stubbed_user_email, sub:)
    end

    let(:sub) { "1#{rand(100_000_000_000_000_000)}" }

    context 'when the user already exists in the database' do
      let(:stubbed_user_email) { user.email }
      let(:user) { users(:user) }

      context 'when the user does not have a google_sub in the database' do
        before { expect(user.google_sub).to eq(nil) }

        it 'allows the user to log in with Google' do
          visit(new_user_session_path)
          expect(page).to have_css('button.google-login')

          expect { click_on(class: 'google-login') }.not_to change { User.count }

          expect(page).to have_current_path(root_path)
          expect(page).to have_text('David Runger Full stack web developer')

          expect(sign_in_confirmed_via_my_account?(user)).to eq(true)
        end
      end

      context 'when the user has a google_sub in the database' do
        context 'when the sub returned from Google matches the google_sub in our database' do
          before { user.update!(google_sub: sub) }

          it 'allows the user to log in with Google' do
            visit(new_user_session_path)
            expect(page).to have_css('button.google-login')

            expect { click_on(class: 'google-login') }.not_to change { User.count }

            expect(page).to have_current_path(root_path)
            expect(page).to have_text('David Runger Full stack web developer')

            expect(sign_in_confirmed_via_my_account?(user)).to eq(true)
          end
        end

        context 'when the sub returned from Google does not match the google_sub in our database' do
          before { user.update!(google_sub: (Integer(sub) + 1).to_s) }

          it 'redirects with an error message and does not sign in the user' do
            visit(new_user_session_path)
            expect(page).to have_css('button.google-login')

            expect { click_on(class: 'google-login') }.not_to change { User.count }

            expect(page).to have_current_path(new_user_session_path)
            expect(page).to have_flash_message(<<~FLASH.squish, type: :alert)
              You are attempting a domain identity takeover attack. Blocked!
            FLASH

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

      it 'allows a user to sign up (and log in) with Google' do
        visit(new_user_session_path)
        expect(page).to have_css('button.google-login')

        expect { click_on(class: 'google-login') }.to change { User.count }.by(1)
        user = User.find_by!(email: stubbed_user_email)

        expect(sign_in_confirmed_via_my_account?(user)).to eq(true)
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
        expect(page).to have_css('button.google-login')

        click_on(class: 'google-login')

        expect(page).to have_text(google_response_content)
      end
    end
  end
end
