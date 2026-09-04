RSpec.describe 'Groceries app' do
  include Features::GroceriesHelpers

  # NOTE: We are using a fixed email here because it must be stable for the Percy snapshot.
  let(:user) { users(:user).tap { it.update!(email: 'groceries-user@gmail.com') } }

  context 'when a user is signed in' do
    before { sign_in(user) }

    let(:invite_prompt) do
      "Tip: You and your partner can automatically view each other's lists."
    end

    context 'when the viewport is compact' do
      around do |example|
        window = page.current_window
        original_window_size = window.size
        window.resize_to(375, 800)
        example.run
      ensure
        if original_window_size
          page.current_window.resize_to(*original_window_size)
        end
      end

      it 'overlays the store with the stores drawer' do
        store = user.stores.reorder(:viewed_at).last!
        other_store = user.stores.where.not(id: store).first!

        visit groceries_path

        main_width = page.evaluate_script(
          'document.querySelector("#groceries-app > main").getBoundingClientRect().width',
        )
        expect(page).to have_css('aside[aria-hidden="true"]')

        click_on('Show stores sidebar')

        expect(page).to have_css('aside.drawer-open')
        expect(
          page.evaluate_script(
            'document.querySelector("#groceries-app > main").getBoundingClientRect().width',
          ),
        ).to eq(main_width)

        within('aside') do
          click_on(other_store.name)
        end

        expect(page).to have_css('h1', text: other_store.name)
        expect(page).to have_css('aside[aria-hidden="true"]')
      end
    end

    context 'when the user has a spouse' do
      before { expect(user.spouse).to be_present }

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

      context 'when viewing a private store' do
        let!(:private_store) { existing_store.tap { it.update!(private: true) } }

        it 'shows a lock icon in the store heading' do
          visit groceries_path

          within('aside') do
            click_on(private_store.name)
          end

          within('h1') do
            expect(page).to have_text(private_store.name)
            expect(page).to have_css('[aria-label="Private store"]')
          end
        end
      end

      context 'when renaming a store' do
        it 'updates the store name from the settings menu' do
          visit groceries_path

          within('aside') do
            click_on(existing_store.name)
          end

          click_store_setting(existing_store, 'Rename')

          canceled_store_name = 'Canceled store name'
          within('.modal-container') do
            expect(page).to have_modal_heading("Rename '#{existing_store.name}'")
            expect(page).to have_field(
              'New store name',
              with: existing_store.name,
            )
            expect(page).to have_css('.rename-store-form input:focus')

            fill_in('New store name', with: canceled_store_name)
            click_on('Cancel')
          end

          expect(page).to have_css('h1', text: existing_store.name)
          expect(page).not_to have_text(canceled_store_name)

          click_store_setting(existing_store, 'Rename')

          renamed_store_name = "Renamed #{existing_store.name}"
          within('.modal-container') do
            fill_in('New store name', with: renamed_store_name)
            click_on('Save')
          end

          expect(page).to have_css('h1', text: renamed_store_name)
          expect(existing_store.reload.name).to eq(renamed_store_name)
        end
      end

      context "when managing a store's privacy" do
        it 'updates the store privacy from the settings menu' do
          visit groceries_path

          within('aside') do
            click_on(existing_store.name)
          end

          expect(page).not_to have_button('Make private')
          expect(page).not_to have_button('Make public')

          click_store_setting(existing_store, 'Privacy')

          within('.modal-container') do
            expect(page).to have_modal_heading("Privacy for #{existing_store.name}")
            expect(page).to have_checked_field('Public')
            expect(page).not_to have_checked_field('Private')
            expect(page).to have_text('Your spouse can view this store.')
            expect(page).to have_text('Only you can view this store.')
            expect(page).to have_button('Save', disabled: true)

            choose('Private')

            expect(page).to have_button('Save', disabled: false)
            click_on('Save')
          end

          within('h1') do
            expect(page).to have_css('[aria-label="Private store"]')
          end
          expect(existing_store.reload).to be_private
        end
      end

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
end
