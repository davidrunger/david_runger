RSpec.describe 'Groceries app' do
  # NOTE: We are using a fixed email here because it must be stable for the Percy snapshot.
  let(:user) { users(:user).tap { it.update!(email: 'groceries-user@gmail.com') } }

  context 'when a user is signed in' do
    before { sign_in(user) }

    let(:invite_prompt) do
      "Tip: You and your partner can automatically view each other's lists."
    end

    context 'when the user has a spouse' do
      before { expect(user.spouse).to be_present }

      let(:new_item_name) { "blueberries (#{url_in_item_name})" }
      let(:url_in_item_name) { 'https://www.amazon.com/blueberries' }

      it 'allows adding, renaming, deleting, and undoing an item, and checking in a shopping trip', :versioning do
        visit groceries_path

        store = user.stores.reorder(:viewed_at).last!
        expect(page).to have_text(store.name)
        expect(page).to have_button('Check in items')

        needed_item = store.items.needed.first!
        unneeded_item = store.items.unneeded.first!
        expect(page).to have_text(/#{needed_item.name} +\(#{needed_item.needed}\)/)

        find(:fillable_field, 'itemName').send_keys(new_item_name)
        find('[role="option"]', text: "Add '#{new_item_name}'", exact_text: true).click

        expect(page).not_to have_spinner
        expect(find(:fillable_field, 'itemName').value).to eq('')

        # Verify that the item is listed only once.
        expect(page.text.scan(new_item_name).size).to eq(1)
        # Verify that the URL in the item name is automatically linkified.
        expect(page).to have_link(url_in_item_name, href: url_in_item_name)

        take_percy_snapshot('Groceries')

        # Rename an item through the actions menu, including canceling an edit.
        click_item_action(needed_item, 'Rename')

        canceled_item_name = 'Canceled item name'
        within('.modal-container') do
          expect(page).to have_text("Rename '#{needed_item.name}'")
          expect(page).to have_field('New item name', with: needed_item.name)
          expect(page).to have_css('.rename-item-form input:focus')

          fill_in('New item name', with: canceled_item_name)
          click_on('Cancel')
        end

        expect(page).to have_css('.grocery-item', text: needed_item.name)
        expect(page).not_to have_text(canceled_item_name)

        click_item_action(needed_item, 'Rename')

        renamed_needed_item_name = "Renamed #{needed_item.name}"
        within('.modal-container') do
          fill_in('New item name', with: renamed_needed_item_name)
          click_on('Save')
        end

        expect(page).not_to have_spinner
        expect(page).to have_css('.grocery-item', text: renamed_needed_item_name)

        # Confirm expected item is in list.
        expect(page).to have_css('.grocery-item', text: unneeded_item.name)

        # Delete the item.
        unneeded_item_dom_id = "#grocery-item-#{unneeded_item.id}"
        click_item_action(unneeded_item, 'Delete')

        sleep(0.01)

        # Confirm that the deleted item is no longer listed.
        expect(page).not_to have_css(unneeded_item_dom_id)
        expect(page).not_to have_css('.grocery-item', text: unneeded_item.name)

        # Undo the deletion
        click_on('Undo')

        # Confirm that the item is listed again.
        expect(page).to have_css('.grocery-item', text: unneeded_item.name)

        click_on('Check in items')

        within_section('Needed') do
          expect(page).to have_text(renamed_needed_item_name)
          expect(page).to have_text(new_item_name)
        end
        expect(page).not_to have_section(/in cart/i)
        expect(page).not_to have_section(/skipped/i)

        check(new_item_name)

        within_section('Needed') do
          expect(page).to have_text(renamed_needed_item_name)
          expect(page).not_to have_text(new_item_name)
        end
        within_section('In Cart') do
          expect(page).not_to have_text(renamed_needed_item_name)
          expect(page).to have_text(new_item_name)
        end
        expect(page).not_to have_section(/skipped/i)

        within_section('Needed') do
          expected_label_text =
            if needed_item.needed > 1
              "#{renamed_needed_item_name} (#{needed_item.needed})"
            else
              renamed_needed_item_name
            end

          needed_item_li = find('label', text: expected_label_text).ancestor('li')

          within(needed_item_li) do
            click_on('Skip')
          end
        end

        expect(page).not_to have_section(/needed/i)
        within_section('In Cart') do
          expect(page).not_to have_text(renamed_needed_item_name)
          expect(page).to have_text(new_item_name)
        end
        within_section('Skipped') do
          expect(page).to have_text(renamed_needed_item_name)
          expect(page).not_to have_text(new_item_name)
        end

        click_on('Check in items in cart')

        expect(page).to have_vue_toast('Check-in successful!')
        expect_needed(new_item_name, 0)
        # Check that the needed count for the skipped item is still positive.
        expect(needed_item.needed).to be > 0
      end

      context "when viewing the spouse's store" do
        let(:spouse_store) do
          user.spouse.presence!.stores.find_by!(private: false)
        end
        let(:spouse_item) { spouse_store.items.first! }
        let(:spouse_new_item_name) { 'Spouse blueberries' }

        it 'searches and adds items' do
          Cuprite::BrowserLogger.ignore_browser_log_entries_matching(
            'source' => 'network',
            'text' => /status.*422/i,
            'url' => %r{/api/items/#{spouse_item.id}\z},
          )

          visit groceries_path

          within('aside') do
            click_on(spouse_store.name)
          end

          expect(page).to have_css('h1', text: spouse_store.name)

          item_input = find(:fillable_field, 'Add or search items')
          item_input.send_keys('banana')

          expect(page).to have_css(
            '[role="option"]',
            text: "#{spouse_item.name} (#{spouse_item.needed})",
            exact_text: true,
          )
          item_input.send_keys([:control, 'a'], spouse_new_item_name)
          expect(page).to have_css(
            '[role="option"]',
            text: "Add '#{spouse_new_item_name}'",
            exact_text: true,
          )

          find(
            '[role="option"]',
            text: "Add '#{spouse_new_item_name}'",
            exact_text: true,
          ).click

          expect(page).to have_css('.grocery-item', text: spouse_new_item_name)

          open_item_actions(spouse_item)
          expect(page).to have_css(
            '[role="menuitem"]',
            text: 'Rename',
            exact_text: true,
          )
          expect(page).not_to have_css(
            '[role="menuitem"]',
            text: 'Available at...',
            exact_text: true,
          )
          expect(page).not_to have_css(
            '[role="menuitem"]',
            text: 'Delete',
            exact_text: true,
          )

          find(
            '[role="menuitem"]',
            text: 'Rename',
            exact_text: true,
          ).click
          within('.modal-container') do
            fill_in('New item name', with: "  #{spouse_new_item_name.swapcase}  ")
            click_on('Save')

            expect(page).to have_text(
              'That name is already taken. Choose a different name.',
            )
            expect(page).not_to have_button('Combine items')
            click_on('Cancel')
          end
        end
      end

      context 'when the spouse has no stores' do
        before do
          user.spouse.presence!.stores.includes(:items).find_each(&:destroy!)
        end

        it 'does not show a prompt to invite the spouse' do
          visit groceries_path

          expect(page).to have_css('aside')
          expect(page).not_to have_text(invite_prompt)
        end
      end
    end

    context 'when the user does not have a spouse' do
      before { expect(user.marriage).to be_blank }

      let(:user) { users(:single_user) }

      it 'has a link to invite a partner' do
        visit groceries_path

        expect(page).to have_text(invite_prompt)

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
          Cuprite::BrowserLogger.ignore_browser_log_entries_matching(
            'source' => 'network',
            'text' => /status.*422/i,
            'url' => %r{/api/stores\z},
          )

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
        let(:existing_item) { existing_store.items.needed.first! }
        let(:other_store) { user.stores.where.not(id: existing_store).first! }
        let(:unneeded_item) { existing_store.items.unneeded.first! }
        let!(:item_available_elsewhere) do
          create(
            :item,
            stores: [other_store],
            name: 'bags available elsewhere',
            needed: 2,
          )
        end
        let!(:item_to_merge_into) do
          create(
            :item,
            stores: [other_store],
            name: 'bags to combine',
            needed: 1,
          )
        end

        context 'when the user searches for an item' do
          let(:item_input_name) { 'itemName' }

          it 'offers matching, available, and new items and handles their selections' do
            Cuprite::BrowserLogger.ignore_browser_log_entries_matching(
              'source' => 'network',
              'text' => /status.*422/i,
              'url' => %r{/api/items/#{existing_item.id}\z},
            )

            visit(groceries_path)

            within('aside') do
              click_on(existing_store.name)
            end

            expect(page).to have_css('h1', text: existing_store.name)

            item_input = find(:fillable_field, 'Add or search items')
            item_input.click
            expect(page.evaluate_script('document.activeElement?.name')).to(
              eq(item_input_name),
            )

            substring_of_existing_item_name = existing_item.name[1..4]
            item_input.send_keys(substring_of_existing_item_name)

            existing_item_option_text = "#{existing_item.name} (#{existing_item.needed})"
            add_item_option_text = "Add '#{substring_of_existing_item_name}'"
            expect(page).to have_css(
              '[role="option"]',
              text: existing_item_option_text,
              exact_text: true,
            )
            expect(page).to have_css(
              '[role="option"]',
              text: add_item_option_text,
              exact_text: true,
            )
            expect(first('[role="option"]').text).to eq(add_item_option_text)

            page.execute_script(<<~JS)
              HTMLElement.prototype.scrollIntoView = function() {
                this.dataset.scrolledIntoView = 'true';
              };
            JS

            find(
              '[role="option"]',
              text: existing_item_option_text,
              exact_text: true,
            ).click

            expect(page).not_to have_spinner
            expect(page).to have_css(
              "#grocery-item-#{existing_item.id}[data-scrolled-into-view='true']",
            )
            expect(page).to have_css("#grocery-item-#{existing_item.id}.highlighted")
            expect(page.evaluate_script('document.activeElement?.name')).not_to(
              eq(item_input_name),
            )

            item_input.send_keys(unneeded_item.name)
            expect(page).to have_css(
              '[role="option"]',
              text: unneeded_item.name,
              exact_text: true,
            )

            item_input.send_keys(
              [:control, 'a'],
              item_available_elsewhere.name.swapcase,
            )
            expect(page).to have_css('[role="option"]', count: 1)
            available_item_option = find('[role="option"]')
            expect(available_item_option).to have_text(
              "Add '#{item_available_elsewhere.name}' to #{existing_store.name}",
            )
            expect(available_item_option).to have_text(
              "Also available at #{other_store.name}; quantity will be shared",
            )
            available_item_option.click

            expect(page).to have_css(
              "#grocery-item-#{item_available_elsewhere.id}.highlighted",
            )
            expect(item_available_elsewhere.reload.store_ids).to(
              include(existing_store.id),
            )

            unique_new_item_name = "#{existing_item.name} #{SecureRandom.alphanumeric(5)}"

            item_input.send_keys([:control, 'a'], unique_new_item_name)
            find(
              '[role="option"]',
              text: "Add '#{unique_new_item_name}'",
              exact_text: true,
            ).click

            new_item = find('.grocery-item', text: unique_new_item_name)
            expect(new_item[:'data-scrolled-into-view']).to eq('true')
            expect(new_item[:class]).to include('highlighted')
            expect(page.evaluate_script('document.activeElement?.name')).not_to(
              eq(item_input_name),
            )

            click_item_action(existing_item, 'Rename')

            within('.modal-container') do
              fill_in('New item name', with: "  #{item_to_merge_into.name.swapcase}  ")
              click_on('Save')

              conflict_message =
                "An item named \"#{item_to_merge_into.name}\" already exists at " \
                "#{other_store.name}."
              expect(page).to have_text(conflict_message)
              expect(page).to have_text(existing_store.name)
              expect(page).to have_text('keep the highest needed amount (2)')
              expect(page).to have_text('This cannot be undone.')
              click_on('Combine items')
            end

            expect(page).not_to have_spinner
            expect(page).not_to have_css("#grocery-item-#{existing_item.id}")
            expect(page).to have_css(
              "#grocery-item-#{item_to_merge_into.id}.highlighted",
            )
            expect(Item.find_by(id: existing_item)).to be_nil
            expect(item_to_merge_into.reload.store_ids).
              to contain_exactly(existing_store.id, other_store.id)
            expect(item_to_merge_into.needed).to eq(2)
          end
        end
      end

      context 'when switching between stores' do
        before { expect(user.stores.size).to be >= 2 }

        let!(:most_recent_store) { user.stores.reorder(viewed_at: :desc).first! }
        let!(:other_store) { user.stores.reorder(viewed_at: :desc).second! }

        it 'shares, checks in, and repeatedly deletes and restores an item', :versioning do
          shared_item = most_recent_store.items.needed.first!
          original_needed = shared_item.needed

          visit groceries_path

          click_item_action(shared_item, 'Available at...')

          within('.modal-container') do
            check(other_store.name)
            click_on('Save')
          end

          expect(page).not_to have_spinner

          within('aside') do
            click_on(other_store.name)
          end
          expect(page).to have_css('.grocery-item', text: shared_item.name)

          open_item_actions(shared_item)
          expect(page).to have_css(
            '[role="menuitem"]',
            text: 'Delete from all stores',
            exact_text: true,
          )

          within("#grocery-item-#{shared_item.id}") do
            find_button("Actions for #{shared_item.name}").click
          end
          expect(page).not_to have_css(
            '[role="menuitem"]',
            text: 'Delete from all stores',
            exact_text: true,
          )
          within("#grocery-item-#{shared_item.id}") { click_on('Increment') }
          wait_for { shared_item.reload.needed }.to eq(original_needed + 1)
          expect(page).not_to have_spinner

          within('aside') do
            click_on(most_recent_store.name)
          end
          expect_needed(shared_item.name, original_needed + 1)

          click_on('Check in items')
          click_on('Choose stores')
          within(all('.modal-container').last) do
            check(other_store.name)
            click_on('Done')
          end

          within_section('Needed') do
            expect(page.text.scan(shared_item.name).size).to eq(1)
            check(shared_item.name)
          end
          click_on('Check in items in cart')

          expect_needed(shared_item.name, 0)

          within('aside') do
            click_on(other_store.name)
          end
          expect_needed(shared_item.name, 0)

          2.times do
            click_item_action(shared_item, 'Delete from all stores')

            expect(page).not_to have_css("#grocery-item-#{shared_item.id}")
            within(all('.groceries-toast').last) { click_on('Undo') }
            expect(page).not_to have_spinner
            expect(page).to have_css("#grocery-item-#{shared_item.id}")
          end

          expect(shared_item.reload.store_ids).
            to contain_exactly(most_recent_store.id, other_store.id)
        end

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

  def click_item_action(item, action)
    open_item_actions(item)

    find(
      '[role="menuitem"]',
      text: action,
      exact_text: true,
    ).click
  end

  def open_item_actions(item)
    within("#grocery-item-#{item.id}") do
      find_button("Actions for #{item.name}").click
    end
  end

  def expect_needed(item_name, needed)
    expect(page).to have_text("#{item_name} (#{needed})")
  end
end
