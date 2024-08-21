RSpec.describe 'Emoji Picker' do
  context 'when a user is logged in' do
    before { sign_in(user) }

    let(:user) { users(:user) }

    it 'fuzzy searches for the typed query and allows boosting' do
      # Search for an emoji with typos; expect fuzzy match.
      visit emoji_picker_path
      fill_in('Search for an emoji', with: 'purpl hart')

      expect(page.first('li')).to have_text(/\A💜purple heart\z/)

      # Add a boost.
      click_on('Add a boost')
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
