# frozen_string_literal: true

RSpec.describe 'Groceries app' do
  let(:user) { users(:user) }

  context 'when a user is signed in' do
    before { sign_in(user) }

    context 'when the user has a spouse' do
      before { expect(user.spouse).to be_present }

      let(:new_item_name) { "#{Faker::Food.unique.ingredient}-#{SecureRandom.alphanumeric(5)}" }

      it 'allows adding an item' do
        visit groceries_path

        store = user.stores.reorder(viewed_at: :desc).first!
        expect(page).to have_text(store.name)
        expect(page).to have_button('Check in items')
        expect(page).to have_button('Copy to clipboard')

        item = store.items.first!
        expect(page).to have_text(/#{item.name} +\(#{item.needed}\)/)

        fill_in('newItemName', with: new_item_name)
        first('.store-container button', text: 'Add').click

        sleep(1)
        # verify that the item is listed only once
        expect(page.body.scan(new_item_name).size).to eq(1)
      end
    end
  end
end
