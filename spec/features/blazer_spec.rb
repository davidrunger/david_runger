RSpec.describe 'Blazer', :rack_test_driver do
  subject(:visit_blazer) { visit('/blazer') }

  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user), scope: :admin_user) }

    it 'renders the Blazer homepage / dashboard' do
      visit_blazer

      # Expect list of queries by name and creator.
      expect(page).to have_text('Name Mastermind')
      expect(page).to have_link('New Query')
    end
  end

  context 'when logged in as a mere User' do
    before { sign_in(users(:user)) }

    it 'redirects to the root path', :prerendering_disabled do
      visit_blazer

      expect(page).to have_current_path(new_admin_user_session_path)
      expect(page).to have_flash_message(
        'You need to sign in or sign up before continuing.',
        type: :alert,
      )
    end
  end

  context 'when not logged in' do
    before { Devise.sign_out_all_scopes }

    it 'redirects to the root path', :prerendering_disabled do
      visit_blazer

      expect(page).to have_current_path(new_admin_user_session_path)
      expect(page).to have_flash_message(
        'You need to sign in or sign up before continuing.',
        type: :alert,
      )
    end
  end
end
