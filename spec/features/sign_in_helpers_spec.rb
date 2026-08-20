RSpec.describe 'Feature sign-in helpers' do
  it 'applies a pending sign-in only to the Capybara session that requested it' do
    user = users(:user)
    other_user = User.where.not(id: user).first!

    sign_in(user)
    visit(my_account_path)
    expect(page).to have_text(user.email)

    Capybara.using_session('other user') do
      sign_in(other_user)

      Capybara.using_session(:default) do
        visit(my_account_path)
        expect(page).to have_text(user.email)
      end

      visit(my_account_path)
      expect(page).to have_text(other_user.email)
    end
  end
end
