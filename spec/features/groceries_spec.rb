# frozen_string_literal: true

RSpec.describe 'Groceries app' do
  let(:user) { users(:user) }

  context 'when user is signed in' do
    before { sign_in(user) }

    it 'renders expected content', :js do
      visit groceries_path

      expect(page).to have_text(user.email)

      store = user.stores.reorder(viewed_at: :desc).first!
      expect(page).to have_text(store.name)
      expect(page).to have_button('Check in shopping trip')
      expect(page).to have_button('Text items to phone')
      expect(page).to have_button('Copy to clipboard')

      item = store.items.first!
      expect(page).to have_text(/#{item.name} +\(#{item.needed}\)/)
    end
  end
end
