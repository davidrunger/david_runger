# frozen_string_literal: true

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
        visit(login_path)
        expect(page).to have_css('button.google-login')

        expect { click_button(class: 'google-login') }.not_to change { User.count }

        visit(logs_path)
        expect(page).to have_text(user.email)
      end
    end

    context 'when there is no user in the databse with the email' do
      let(:stubbed_user_email) { "#{SecureRandom.uuid}@gmail.com" }

      before { expect(User.where(email: stubbed_user_email)).not_to exist }

      it 'allows a user to sign up (and log in) with Google' do
        visit(login_path)
        expect(page).to have_css('button.google-login')

        expect { click_button(class: 'google-login') }.to change { User.count }.by(1)
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

      OmniAuth.config.test_mode = original_omni_auth_test_mode
    end

    context 'when Google responds with "This is Google OAuth."' do
      around do |spec|
        page.driver.browser.intercept do |request, &continue|
          if request.url.start_with?('https://accounts.google.com/o/oauth2/auth?')
            page.driver.browser.devtools.fetch.fulfill_request(
              request_id: request.id,
              response_code: 200,
              body: Base64.strict_encode64('This is Google OAuth.'),
            )
          else
            continue.call(request)
          end
        end

        spec.run

        page.driver.browser.devtools.callbacks.clear # might avoid slowing down subsequent requests?
        page.driver.browser.devtools.fetch.disable
      end

      it "renders Google's response" do
        visit(login_path)
        expect(page).to have_css('button.google-login')

        click_button(class: 'google-login')

        expect(page).to have_text('This is Google OAuth.')
      end
    end
  end
end
