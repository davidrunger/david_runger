RSpec.describe 'Ending a marriage' do
  let(:user) { users(:user) }
  let!(:spouse) { user.spouse }
  let(:marriage) { user.marriage }

  before { sign_in(user) }

  it 'allows the user to end the marriage after confirmation' do
    visit marriage_path

    expect(page).to have_button('End marriage')

    accept_confirm { click_on('End marriage') }

    expect(page).to have_flash_message('Your marriage has been ended.')
    expect(Marriage.exists?(marriage.id)).to eq(false)
    expect(user.reload.marriage.partners).to contain_exactly(user)
    expect(spouse.reload.marriage).to be_nil
  end
end
