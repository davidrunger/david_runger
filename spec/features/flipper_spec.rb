RSpec.describe 'Flipper web UI', :rack_test_driver do
  subject(:visit_flipper_web_ui) { visit('/flipper') }

  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user), scope: :admin_user) }

    it 'renders the flipper web UI homepage / dashboard' do
      visit_flipper_web_ui

      expect(page).to have_link('Add Feature')
      expect(page).to have_text("I'll flip your features.")
    end
  end

  context 'when logged in as a mere User' do
    before { sign_in(users(:user)) }

    it 'redirects to the root path', :prerendering_disabled do
      visit_flipper_web_ui

      expect(page).to have_current_path(new_admin_user_session_path)
    end
  end

  context 'when not logged in' do
    before { Devise.sign_out_all_scopes }

    it 'redirects to the root path', :prerendering_disabled do
      visit_flipper_web_ui
      expect(page).to have_current_path(new_admin_user_session_path)
    end
  end
end
