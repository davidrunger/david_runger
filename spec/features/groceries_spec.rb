RSpec.describe 'Groceries app' do
  # NOTE: We are using a fixed email here because it must be stable for the Percy snapshot.
  let(:user) { users(:user).tap { it.update!(email: 'groceries-user@gmail.com') } }

  context 'when a user is signed in' do
    before { sign_in(user) }

    context 'when the user has a spouse' do
      before { expect(user.spouse).to be_present }

      let(:new_item_name) { "blueberries (#{url_in_item_name})" }
      let(:url_in_item_name) { 'https://www.amazon.com/blueberries' }

      it 'allows adding an item (which it linkifies), deleting an item, undoing the deletion, and checking in a shopping trip', :versioning do
        visit groceries_path

        store = user.stores.reorder(:viewed_at).last!
        expect(page).to have_text(store.name)
        expect(page).to have_button('Check in items')

        needed_item = store.items.needed.first!
        unneeded_item = store.items.unneeded.first!
        expect(page).to have_text(/#{needed_item.name} +\(#{needed_item.needed}\)/)

        # NOTE: When running specs with the development vite server, the
        # following line triggers two warnings, which I'm pretty sure are caused
        # by a bug in cuprite (namely that focus and blur events are of type
        # Event rather than FocusEvent). github.com/rubycdp/cuprite/pull/ 272
        fill_in('newItemName', with: new_item_name)
        find(:button, 'Add item').click

        expect(page).not_to have_spinner
        expect(find(:fillable_field, 'newItemName').value).to eq('')
        # The add-new-item button should be disabled, now that it has no value (so it's not valid).
        within(find('.item-name-input').ancestor('form')) do
          expect(find(:link_or_button, 'Add', disabled: true)).to be_disabled
        end

        # Verify that the item is listed only once.
        expect(page.text.scan(new_item_name).size).to eq(1)
        # Verify that the URL in the item name is automatically linkified.
        expect(page).to have_link(url_in_item_name, href: url_in_item_name)

        page.percy_snapshot('Groceries')

        # Confirm expected item is in list.
        expect(page).to have_css('.grocery-item', text: unneeded_item.name)

        # Delete the item.
        within('.grocery-item', text: unneeded_item.name) do
          find(:link_or_button, 'Delete item').click
          sleep(0.01)
          expect(page).not_to have_selector(:link_or_button, 'Delete item')
        end

        # Confirm that the deleted item is no longer listed.
        expect(page).not_to have_css('.grocery-item', text: unneeded_item.name)

        # Undo the deletion
        click_on('Undo')

        # Confirm that the item is listed again.
        expect(page).to have_css('.grocery-item', text: "#{unneeded_item.name}z")

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
        expect_needed(new_item_name, 0)
        # Check that the needed count for the skipped item is still positive.
        expect(needed_item.needed).to be > 0
      end
    end

    context 'when the user does not have a spouse' do
      before { expect(user.marriage).to be_blank }

      let(:user) { users(:single_user) }

      it 'has a link to invite a partner' do
        visit groceries_path

        expect(page).to have_text(
          "Tip: You and your partner can automatically view each other's lists.",
        )

        click_on('Invite them to join.')

        expect(page).to have_current_path(new_marriage_path, ignore_query: true)
        expect(page).to have_text('Enter the email of your spouse')

        fill_in('Spouse email', with: Faker::Internet.email)
        click_on('Submit')

        expect(page).to have_current_path(groceries_path)
        expect(page).to have_vue_toast('Invitation sent.')
      end
    end

    context 'when the user has a store' do
      before { expect(user.stores).to exist }

      let(:existing_store) { user.stores.first! }

      context 'when the user attempts to recreate a store' do
        it 'displays a toast message and allows (re)submitting with a unique store name' do
          visit(groceries_path)

          fill_in('Add a store', with: existing_store.name)
          within('form.add-store') do
            click_on('Add')
          end

          expect(page).to have_vue_toast('Name has already been taken', type: :error)
          # Make sure that a duplicate store is not created in the sidebar.
          within('aside') do
            count_of_store_name_in_page = page.text.scan(existing_store.name).count
            expect(count_of_store_name_in_page).to eq(1)
          end

          unique_new_store_name = "#{existing_store.name} #{SecureRandom.alphanumeric(5)}"
          fill_in('Add a store', with: unique_new_store_name)
          within('form.add-store') do
            click_on('Add')
          end

          # Make sure that the new store is added to the list.
          within('aside') do
            expect(page).to have_text(unique_new_store_name)
          end
        end
      end

      context 'when the store has an item' do
        let(:existing_store) { user.stores.joins(:items).first! }
        let(:existing_item) { existing_store.items.first! }

        context 'when the user attempts to add a duplicate item' do
          it 'displays a toast message and allows (re)submitting with a unique item name' do
            visit(groceries_path)

            within('aside') do
              click_on(existing_store.name)
            end

            expect(page).to have_css('h1', text: existing_store.name)

            fill_in('Add an item', with: existing_item.name)
            click_on('Add item')

            expect(page).to have_vue_toast('Name has already been taken', type: :error)

            unique_new_item_name = "#{existing_item.name} #{SecureRandom.alphanumeric(5)}"

            fill_in('Add an item', with: unique_new_item_name)
            click_on('Add item')

            expect(page).to have_css('li', text: unique_new_item_name)
          end
        end
      end

      context 'when switching between stores' do
        before { expect(user.stores.size).to be >= 2 }

        let!(:most_recent_store) { user.stores.reorder(viewed_at: :desc).first! }
        let!(:other_store) { user.stores.reorder(viewed_at: :desc).second! }

        it 'includes the store name in the page title' do
          visit groceries_path

          expect(page).to have_css('h1', text: most_recent_store.name)
          expect(page).to have_title("#{most_recent_store.name} - Groceries - David Runger")

          within('aside') do
            click_on(other_store.name)
          end

          expect(page).to have_css('h1', text: other_store.name)
          expect(page).to have_title("#{other_store.name} - Groceries - David Runger")
        end
      end
    end
  end

  def expect_needed(item_name, needed)
    expect(page).to have_text("#{item_name} (#{needed})")
  end
end
