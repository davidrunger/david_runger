# frozen_string_literal: true

RSpec.describe 'Public files functionality', :prerendering_disabled do
  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user), scope: :admin_user) }

    it 'supports uploading a public file and viewing an index list' do
      visit new_public_file_path
      attach_file('public_file', Rails.root.join('app/assets/images/david.jpg'))
      click_on('Upload file')
      expect(page).to have_text('Public file uploaded successfully!')
      expect(page).to have_link('david.jpg')
    end
  end

  context 'when logged in as a mere User' do
    before { sign_in(users(:user)) }

    it 'redirects to the root path', :prerendering_disabled do
      visit new_public_file_path
      expect(page).to have_current_path(admin_login_path)
    end
  end

  context 'when not logged in' do
    before { Devise.sign_out_all_scopes }

    it 'redirects to the root path', :prerendering_disabled do
      visit new_public_file_path
      expect(page).to have_current_path(admin_login_path)
    end
  end
end
