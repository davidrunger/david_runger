# frozen_string_literal: true

RSpec.describe 'Flipper web UI', :rack_test_driver do
  subject(:visit_flipper_web_ui) { visit('/flipper') }

  context 'when logged in as an admin user' do
    before do
      expect(user).to be_admin
      sign_in(user)
    end

    let(:user) { users(:admin) }

    it 'renders the flipper web UI homepage / dashboard' do
      visit_flipper_web_ui
      expect(page).to have_link('Add Feature')
      expect(page).to have_text("I'll flip your features.")
    end
  end

  context 'when logged in as a nonadmin user' do
    before do
      expect(user).not_to be_admin
      sign_in(user)
    end

    let(:user) { users(:user) }

    it 'raises a RoutingError' do
      expect { visit_flipper_web_ui }.to raise_error(
        ActionController::RoutingError,
        'No route matches [GET] "/flipper"',
      )
    end
  end

  context 'when not logged in' do
    before { Devise.sign_out_all_scopes }

    it 'redirects to the login page' do
      visit_flipper_web_ui
      expect(page).to have_current_path(login_path)
    end
  end
end
