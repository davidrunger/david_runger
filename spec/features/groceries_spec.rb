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

        needed_item = store.items.needed.first!
        expect(page).to have_text(/#{needed_item.name} +\(#{needed_item.needed}\)/)

        fill_in('newItemName', with: new_item_name)
        first('.store-container button', text: 'Add').click

        sleep(1)
        # verify that the item is listed only once
        expect(page.body.scan(new_item_name).size).to eq(1)

        click_on('Check in items')

        within_section('Needed') do
          expect(page).to have_text(needed_item.name)
          expect(page).to have_text(new_item_name)
        end
        expect(page).not_to have_section(/in cart/i)
        expect(page).not_to have_section(/skipped/i)

        check(new_item_name)

        within_section('Needed') do
          expect(page).to have_text(needed_item.name)
          expect(page).not_to have_text(new_item_name)
        end
        within_section('In Cart') do
          expect(page).not_to have_text(needed_item.name)
          expect(page).to have_text(new_item_name)
        end
        expect(page).not_to have_section(/skipped/i)

        within_section('Needed') do
          needed_item_li =
            find('label', text: "#{needed_item.name} (#{needed_item.needed})").
              ancestor('li')

          within(needed_item_li) do
            click_on('Skip')
          end
        end

        expect(page).not_to have_section(/needed/i)
        within_section('In Cart') do
          expect(page).not_to have_text(needed_item.name)
          expect(page).to have_text(new_item_name)
        end
        within_section('Skipped') do
          expect(page).to have_text(needed_item.name)
          expect(page).not_to have_text(new_item_name)
        end
      end
    end
  end
end
