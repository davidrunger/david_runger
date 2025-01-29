RSpec.describe 'Logging in as a User via Google auth', :prerendering_disabled do
  context 'when OmniAuth test mode is enabled and OmniAuth is mocked' do
    before do
      expect(OmniAuth.config.test_mode).to eq(true)
      MockOmniAuth.google_oauth2(email: stubbed_user_email)
    end

    context 'when the user already exists in the database' do
      let(:stubbed_user_email) { user.email }
      let(:user) { users(:user) }

      it 'allows a user to log in with Google' do
        visit(new_user_session_path)
        expect(page).to have_css('button.google-login')

        expect { click_on(class: 'google-login') }.not_to change { User.count }

        expect(page).to have_current_path(root_path)
        expect(page).to have_text('David Runger Full stack web developer')

        visit(logs_path)
        expect(page).to have_text(user.email)
      end
    end

    context 'when there is no user in the databse with the email' do
      let(:stubbed_user_email) { "#{SecureRandom.uuid}@gmail.com" }

      before { expect(User.where(email: stubbed_user_email)).not_to exist }

      it 'allows a user to sign up (and log in) with Google' do
        visit(new_user_session_path)
        expect(page).to have_css('button.google-login')

        expect { click_on(class: 'google-login') }.to change { User.count }.by(1)
        user = User.find_by!(email: stubbed_user_email)

        visit(logs_path)
        expect(page).to have_text(user.email)
      end
    end
  end

  context 'when OmniAuth test mode is disabled' do
    around do |spec|
      original_omni_auth_test_mode = OmniAuth.config.test_mode
      OmniAuth.config.test_mode = false

      spec.run
    ensure
      OmniAuth.config.test_mode = original_omni_auth_test_mode
    end

    context 'when Google responds with "This is Google OAuth."' do
      let(:google_response_content) { 'This is Google OAuth.' }

      around do |spec|
        browser = page.driver.browser
        browser.network.intercept
        browser.on(:request) do |request|
          if request.match?(%r{\Ahttps://accounts.google.com/o/oauth2/auth\?})
            request.respond(body: google_response_content)
          else
            request.continue
          end
        end

        spec.run
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
