RSpec.describe 'My account', :rack_test_driver do
  context 'when a user is signed in' do
    before { sign_in(user) }

    let(:user) { users(:user) }

    it 'allows the user to update their public name' do
      visit(my_account_path)

      expect(page.find(:fillable_field, 'Public name (optional)').value).to eq(user.public_name)

      new_public_name = Faker::Name.name
      fill_in('Public name (optional)', with: new_public_name)
      click_on('Update')

      expect(page).to have_current_path(my_account_path)
      expect(page).to have_flash_message('Updated successfully.')
      expect(page.find(:fillable_field, 'Public name (optional)').value).to eq(new_public_name)
    end
  end
end
