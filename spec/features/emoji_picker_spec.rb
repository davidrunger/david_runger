RSpec.describe 'Emoji Picker' do
  let(:add_a_boost_text) { 'Add a boost' }
  let(:log_in_for_boosting_text) { /Tip: log in to customize .* search keywords/ }

  context 'when not logged in' do
    before { Devise.sign_out_all_scopes }

    it 'fuzzy searches for the typed query and mentions option to log in for boosting' do
      # Search for an emoji with typos; expect fuzzy match.
      visit emoji_picker_path
      fill_in('Search for an emoji', with: 'purpl hart')

      expect(page.first('li')).to have_text(/\A💜purple heart\z/)

      # Check that tip about logging in is shown, and boosting interface is not.
      expect(page).to have_text(log_in_for_boosting_text)
      expect(page).not_to have_text(add_a_boost_text)
      expect(page).to have_text('Not there!')
    end
  end

  context 'when a user is logged in' do
    before { sign_in(user) }

    let(:user) { users(:user) }

    it 'fuzzy searches for the typed query and allows boosting' do
      # Search for an emoji with typos; expect fuzzy match.
      visit emoji_picker_path
      fill_in('Search for an emoji', with: 'purpl hart')

      expect(page.first('li')).to have_text(/\A💜purple heart\z/)

      # Check that page does not have tip about logging in (as user is already logged in).
      expect(page).not_to have_text(log_in_for_boosting_text)

      # Add a boost.
      click_on(add_a_boost_text)
      within('tbody tr:last-of-type') do
        fill_in('Symbol', with: '😃')
        fill_in('Keyword to boost', with: 'delighted')
      end
      click_on('Save boosts')

      # Test that the boost fuzzily surfaces its target emoji.
      fill_in('Search for an emoji', with: 'delghtd')

      expect(page.first('li')).to have_text(/\A😃delighted\z/)

      # Make sure that the boost persists after reload.
      visit emoji_picker_path
      fill_in('Search for an emoji', with: 'dlightd')

      expect(page.first('li')).to have_text(/\A😃delighted\z/)
    end
  end
end
