RSpec.describe 'Groceries app' do
  include Features::GroceriesHelpers

  # NOTE: We are using a fixed email here because it must be stable for the Percy snapshot.
  let(:user) { users(:user).tap { it.update!(email: 'groceries-user@gmail.com') } }

  context 'when a user is signed in' do
    before { sign_in(user) }

    context 'when the user has a spouse' do
      before { expect(user.spouse).to be_present }

      context 'when the viewport is slightly wider than compact', viewport_size: [900, 800] do
        it 'displays store sections modals over the stores sidebar' do
          store = user.stores.reorder(:viewed_at).last!

          visit groceries_path

          click_store_setting(store, 'Store sections')

          modal_is_above_sidebar = page.evaluate_script(<<~JAVASCRIPT)
            (() => {
              const modal = document.querySelector('.modal-container');
              const { left, top, height } = modal.getBoundingClientRect();
              const element = document.elementFromPoint(left + 1, top + height / 2);

              return element.closest('.modal-container') === modal;
            })()
          JAVASCRIPT

          expect(modal_is_above_sidebar).to be(true)
        end
      end

      it 'lets the user manage sections and assign an item to one' do
        store = user.stores.reorder(:viewed_at).last!
        item = store.items.needed.first!

        visit groceries_path

        click_store_setting(store, 'Store sections')
        sections_modal_heading = "Sections for #{store.name}"
        within('.modal-container') do
          expect(page).to have_modal_heading(sections_modal_heading)
          fill_in('Add a section', with: 'Frozen')
          click_on('Add')
          expect(page).to have_field(with: 'Frozen')
          section_name_input = find_field('Name for Frozen')
          section_name_input.fill_in(with: 'Frozen foods')
          click_on('Done')
        end
        expect(page).not_to have_modal_heading(sections_modal_heading)

        click_item_action(item, 'Change section')
        within('.modal-container') do
          find('.el-select').click
        end
        find('[role="option"]', text: 'Frozen foods', exact_text: true).click
        within('.modal-container') { click_on('Save') }
        expect(page).not_to have_spinner
        expect(page).not_to have_modal_heading('Change section')

        expect(
          item_section_assignments(:item_section_assignment).reload.store_section.name,
        ).to eq('Frozen foods')

        click_store_setting(store, 'Store sections')
        within('.modal-container') do
          click_on('Change layout')
          find('label', text: "This store doesn't need sections", exact_text: true).click
          click_on('Save choice')
        end
        expect(page).not_to have_spinner
        configuration = store_section_configurations(:store_section_configuration).reload
        expect(configuration).not_to be_sectioning_enabled
        expect(configuration.store_section_scheme).to eq(store_section_schemes(:grocery_layout))
        expect(configuration.item_section_assignments).to contain_exactly(
          item_section_assignments(:item_section_assignment),
        )

        click_store_setting(store, 'Store sections')
        within('.modal-container') do
          expect(page).to have_checked_field("This store doesn't need sections", visible: :all)
          find('label', text: 'Use an existing layout', exact_text: true).click
          click_on('Save layout')
          expect(page).to have_modal_heading(sections_modal_heading)
          click_on('Done')
        end
        expect(page).not_to have_spinner
        expect(configuration.reload).to be_sectioning_enabled
        expect(configuration.item_section_assignments).to contain_exactly(
          item_section_assignments(:item_section_assignment),
        )
      end

      it 'organizes an ungrouped needed item during check-in' do
        store = user.stores.reorder(:viewed_at).last!
        item = store.items.needed.first!
        item_section_assignments(:item_section_assignment).destroy!

        visit groceries_path

        click_on('Check in items')
        click_on('Organize 1 ungrouped item')
        expect(page).to have_modal_heading('Organize items')
        within('.modal-container', text: 'Organize items') do
          find('.el-select').click
        end
        find('[role="option"]', text: 'Produce', exact_text: true).click
        within('.modal-container', text: 'Organize items') { click_on('Done') }
        expect(page).not_to have_spinner
        expect(page).not_to have_modal_heading('Organize items')

        within_section('Needed') do
          expect(page).to have_css('h4', text: 'Produce', exact_text: true)
          expect(page).to have_text(item.name)
        end

        click_on('Cancel')
        open_store_settings(store)
        expect(page).to have_css(
          '[role="menuitem"]',
          text: 'Organize all items',
          exact_text: true,
        )
        find(
          '[role="menuitem"]',
          text: 'Organize needed items',
          exact_text: true,
        ).click
        expect(page).to have_modal_heading('Organize items')
        within('.modal-container', text: 'Organize items') { click_on('Skip for now') }
        expect(page).not_to have_modal_heading('Organize items')
      end

      it 'stops offering organization for a store without useful sections' do
        store = user.stores.reorder(:viewed_at).last!
        store_section_configurations(:store_section_configuration).destroy!

        visit groceries_path

        click_on('Check in items')
        click_on('Organize 1 ungrouped item')
        expect(page).to have_modal_heading('Set up store sections')
        within('.modal-container', text: 'Set up store sections') do
          find('label', text: "This store doesn't need sections", exact_text: true).click
          click_on('Continue')
        end
        expect(page).not_to have_spinner
        expect(page).not_to have_modal_heading('Set up store sections')
        expect(page).not_to have_button('Organize 1 ungrouped item')

        click_on('Cancel')
        click_store_setting(store, 'Store sections')
        within('.modal-container') do
          expect(page).to have_modal_heading('Store sections')
          expect(page).to have_checked_field("This store doesn't need sections", visible: :all)
        end
      end

      context 'when a selected store already has a section choice' do
        let(:store) { user.stores.reorder(:viewed_at).last! }
        let(:spouse_store) { user.spouse.stores.find_by!(private: false) }
        let(:sectioning_enabled) { true }

        before do
          store_section_configurations(:store_section_configuration).update!(
            sectioning_enabled:,
          )
          visit groceries_path

          click_on('Check in items')
          click_on('Choose stores')
          within(all('.modal-container').last) do
            check("checkin-stores-#{spouse_store.id}")
            click_on('Done')
          end
          click_on('Organize 1 ungrouped item')
        end

        it 'shows its layout while setting up other stores' do
          within('.modal-container', text: 'Set up store sections') do
            expect(page).to have_css('.setup-store', text: spouse_store.name)
            expect(page).to have_css('.configured-store', text: store.name)
            expect(page).to have_text('Using the Grocery layout layout.')
          end
        end

        context 'when it does not use sections' do
          let(:sectioning_enabled) { false }

          it 'shows that its items will stay ungrouped' do
            within('.modal-container', text: 'Set up store sections') do
              expect(page).to have_css('.setup-store', text: spouse_store.name)
              expect(page).to have_css('.configured-store', text: store.name)
              expect(
                page,
              ).to have_text('Items from this store will stay ungrouped.')
            end
          end
        end
      end

      it 'creates and reuses one layout for identically named stores during setup' do
        store = user.stores.reorder(:viewed_at).last!
        spouse_store = user.spouse.stores.find_by!(private: false)
        store.update!(name: 'Costco')
        spouse_store.update!(name: 'Costco')
        store_section_configurations(:store_section_configuration).destroy!

        visit groceries_path

        click_on('Check in items')
        click_on('Choose stores')
        within(all('.modal-container').last) do
          check("checkin-stores-#{spouse_store.id}")
          click_on('Done')
        end
        click_on('Organize 2 ungrouped items')
        expect(page).to have_modal_heading('Set up store sections')
        expect(page).to have_css('.setup-store', text: 'Costco', count: 2)
        within('.modal-container', text: 'Set up store sections') { click_on('Continue') }
        expect(page).to have_modal_heading(
          'Organize items',
          wait: RSpec.configuration.wait_timeout,
        )

        configurations = user.store_section_configurations.where(store: [store, spouse_store])
        layout = user.store_section_schemes.find_by!(name: 'Costco')
        expect(configurations.count).to eq(2)
        expect(configurations.pluck(:store_section_scheme_id).uniq).to contain_exactly(layout.id)

        within('.modal-container', text: 'Organize items') { click_on('Skip for now') }
        click_on('Cancel')
        configurations.delete_all
        visit groceries_path

        click_on('Check in items')
        click_on('Choose stores')
        within(all('.modal-container').last) do
          check("checkin-stores-#{spouse_store.id}")
          click_on('Done')
        end
        click_on('Organize 2 ungrouped items')
        within('.modal-container', text: 'Set up store sections') { click_on('Continue') }
        expect(page).to have_modal_heading(
          'Organize items',
          wait: RSpec.configuration.wait_timeout,
        )
        expect(configurations.reload.count).to eq(2)
        expect(configurations.pluck(:store_section_scheme_id).uniq).to contain_exactly(layout.id)
      end
    end
  end
end
