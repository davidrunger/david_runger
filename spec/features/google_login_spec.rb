# frozen_string_literal: true

RSpec.describe 'Google auth' do
  around do |spec|
    original_test_mode = OmniAuth.config.test_mode
    OmniAuth.config.test_mode = true
    spec.run
    OmniAuth.config.test_mode = original_test_mode
  end

  before do
    OmniAuth.config.mock_auth[:google_oauth2,] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '12345678910',
      info: {
        email: stubbed_user_email,
      },
      credentials: {
        token: 'abcdefg12345',
        expires_at: 1.hour.from_now,
        expires: true,
      },
    )
  end

  context 'when the user already exists in the database' do
    let(:stubbed_user_email) { user.email }
    let(:user) { users(:user) }

    it 'allows a user to log in with Google', :js do
      visit(login_path)
      expect(page).to have_button('Sign in with Google')

      expect { click_button('Sign in with Google') }.not_to change { User.count }

      visit(groceries_path)
      expect(page).to have_text(user.email)
    end
  end

  context 'when there is no user in the databse with the email' do
    let(:stubbed_user_email) { "#{SecureRandom.uuid}@gmail.com" }

    before { expect(User.where(email: stubbed_user_email)).not_to exist }

    it 'allows a user to sign up (and log in) with Google', :js do
      visit(login_path)
      expect(page).to have_button('Sign in with Google')

      expect { click_button('Sign in with Google') }.to change { User.count }.by(1)
      user = User.find_by!(email: stubbed_user_email)

      visit(groceries_path)
      expect(page).to have_text(user.email)
    end
  end
end
