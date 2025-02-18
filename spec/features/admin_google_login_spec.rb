RSpec.describe 'Logging in as an AdminUser via Google auth' do
  before { MockOmniAuth.google_oauth2(email: stubbed_admin_user_email, sub: rand(100_000_000_000)) }

  context 'when an AdminUser with the email exists in the database' do
    let(:stubbed_admin_user_email) { admin_user.email }
    let(:admin_user) { admin_users(:admin_user) }

    it 'allows the AdminUser to log in via Google' do
      visit(new_admin_user_session_path)

      expect(page).to have_css('button.google-login')

      expect { click_on(class: 'google-login') }.not_to change { AdminUser.count }

      visit(admin_root_path)

      expect(page).to have_text('David Runger')
      expect(page).to have_text('Dashboard')
      expect(page).to have_text(/Recent Users.*#{User.last!.email}/)
    end
  end

  context 'when there is no AdminUser in the database with the email' do
    let(:stubbed_admin_user_email) { "#{SecureRandom.uuid}@gmail.com" }

    before { expect(AdminUser.where(email: stubbed_admin_user_email)).not_to exist }

    it 'does not create an AdminUser' do
      visit(new_admin_user_session_path)
      expect(page).to have_css('button.google-login')

      expect { click_on(class: 'google-login') }.not_to change { AdminUser.count }
      expect(AdminUser.find_by(email: stubbed_admin_user_email)).to eq(nil)

      expect(page).to have_flash_message(
        "#{stubbed_admin_user_email} is not authorized to access admin",
        type: :alert,
      )
      expect(page).to have_current_path('/admin/login')
    end
  end
end
