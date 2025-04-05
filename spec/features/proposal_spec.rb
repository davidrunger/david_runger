RSpec.describe 'proposing marriage to another user' do
  subject(:visit_new_marriage_path) { visit(new_marriage_path) }

  context 'when a user is signed in' do
    before { sign_in(user) }

    let(:user) { users(:user) }
    let(:marriage) { user.marriage }

    context 'when the user is in a marriage with a partner', :rack_test_driver do
      before { expect(user.marriage.partners.compact.size).to eq(2) }

      let(:spouse) { user.spouse }

      it 'redirects the user to the check-ins page with a flash message about already being married' do
        visit_new_marriage_path

        expect(page).to have_flash_message('You are already married', type: :alert)
        expect(page).to have_current_path(check_ins_path)
      end
    end
  end
end
