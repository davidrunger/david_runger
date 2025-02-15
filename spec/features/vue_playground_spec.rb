RSpec.describe 'Vue Playground' do
  subject(:visit_vue_playground_path) { visit vue_playground_path }

  context 'when signed in as an AdminUser' do
    before { sign_in(admin_users(:admin_user), scope: :admin_user) }

    it 'says "Welcome to Vue, David!"' do
      visit_vue_playground_path

      expect(page).to have_text('Welcome to Vue, David!')
    end
  end

  context 'when logged in as a mere User' do
    before { sign_in(users(:user)) }

    it 'redirects to the root path', :prerendering_disabled, :rack_test_driver do
      visit_vue_playground_path

      expect(page).to have_current_path(new_admin_user_session_path)
    end
  end

  context 'when not logged in' do
    before { Devise.sign_out_all_scopes }

    it 'redirects to the root path', :prerendering_disabled, :rack_test_driver do
      visit_vue_playground_path

      expect(page).to have_current_path(new_admin_user_session_path)
    end
  end
end
