RSpec.describe 'Account deletion' do
  context 'when a User is logged in' do
    before { sign_in(user) }

    let(:user) { users(:user) }

    it 'allows the user to delete their account and redirects to the homepage with a flash message', :prerendering_disabled do
      visit edit_user_path(user)

      accept_confirm { click_on('Delete Account') }

      expect(page).to have_current_path(root_path)
      expect(page).to have_flash_message('We have deleted your account.', type: :notice)

      expect(User.find_by(id: user.id)).to eq(nil)
    end
  end
end
