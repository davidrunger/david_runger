RSpec.describe 'Account deletion' do
  context 'when a User is logged in' do
    before { sign_in(user) }

    let(:user) { users(:user) }

    it 'allows the user to delete their account and redirects to the homepage with a flash message', :prerendering_disabled do
      visit my_account_path

      accept_confirm { click_on('Delete Account') }

      expect(page).to have_current_path(root_path)
      expect(page).to have_vue_toast('We have deleted your account.')

      expect(User.find_by(id: user.id)).to eq(nil)
    end
  end
end
