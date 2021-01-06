# frozen_string_literal: true

RSpec.describe 'Logging in as a User via Google auth' do
  before { MockOmniAuth.google_oauth2(email: stubbed_user_email) }

  context 'when the user already exists in the database' do
    let(:stubbed_user_email) { user.email }
    let(:user) { users(:user) }

    it 'allows a user to log in with Google' do
      visit(login_path)
      expect(page).to have_css('button.google-login')

      expect { click_button(class: 'google-login') }.not_to change { User.count }

      visit(groceries_path)
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

      visit(groceries_path)
      expect(page).to have_text(user.email)
    end
  end
end
