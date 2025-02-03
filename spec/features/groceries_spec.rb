RSpec.describe 'Groceries app' do
  let(:user) { users(:user) }

  context 'when a user is signed in' do
    before { sign_in(user) }

    context 'when the user has a spouse' do
      before { expect(user.spouse).to be_present }

      let(:new_item_name) { 'blueberries' }

      it 'allows adding an item, deleting an item, undoing the deletion, and checking in a shopping trip' do
        visit groceries_path

        store = user.stores.reorder(viewed_at: :desc).first!
        expect(page).to have_text(store.name)
        expect(page).to have_button('Check in items')

        needed_item = store.items.needed.first!
        unneeded_item = store.items.unneeded.first!
        expect(page).to have_text(/#{needed_item.name} +\(#{needed_item.needed}\)/)

        # NOTE: When running specs with the development vite server, the
        # following line triggers two warnings, which I'm pretty sure are caused
        # by a bug in cuprite (namely that focus and blur events are of type
        # `Event` rather than `FocusEvent`).
        fill_in('newItemName', with: new_item_name)
        first('.store-container button', text: 'Add').click

        expect(page).not_to have_spinner
        expect(find(:fillable_field, 'newItemName').value).to eq('')
        within(find('.item-name-input').ancestor('form')) do
          expect(find(:link_or_button, 'Add', disabled: true)).to be_disabled
        end

        sleep(0.5)
        # verify that the item is listed only once
        expect(page.body.scan(new_item_name).size).to eq(1)

        page.percy_snapshot('Groceries')

        # Confirm expected item is on list.
        expect(page).to have_css('.grocery-item', text: unneeded_item.name)

        # Delete the item.
        within('.grocery-item', text: unneeded_item.name) { click_on('Delete item') }

        # Confirm that the deleted item is no longer listed.
        expect(page).not_to have_css('.grocery-item', text: unneeded_item.name)

        # Undo the deletion
        click_on('Undo')

        # Confirm that the item is listed again.
        expect(page).to have_css('.grocery-item', text: unneeded_item.name)

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
          expected_label_text =
            if needed_item.needed > 1
              "#{needed_item.name} (#{needed_item.needed})"
            else
              needed_item.name
            end

          needed_item_li = find('label', text: expected_label_text).ancestor('li')

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

        click_on('Check in items in cart')

        expect(page).to have_vue_toast('Check-in successful!')
        expect_needed(new_item_name, 10) # expect_needed(new_item_name, 0)
      end
    end
  end

  def expect_needed(item_name, needed)
    expect(page).to have_text("#{item_name} (#{needed})")
  end
end
