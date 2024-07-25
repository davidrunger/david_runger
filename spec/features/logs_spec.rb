RSpec.describe 'Logs app' do
  let(:user) { users(:user) }

  context 'when user is signed in' do
    before { sign_in(user) }

    let(:delete_last_entry_text) { 'Delete last entry' }

    context 'when user has multiple logs' do
      before { expect(user.logs.size).to be >= 2 }

      it 'renders the logs app and allows the user to view a log' do
        visit logs_path

        expect(page).to have_text(user.email)
        user.logs.pluck(:name).presence!.each do |log_name|
          expect(page).to have_text(log_name)
        end
        expect(page).to have_text('New Log')

        log = user.logs.first!
        other_log = user.logs.second!
        click_on(log.name)

        expect(page).to have_current_path("/logs/#{log.slug}")
        expect(page).to have_text(log.name)
        expect(page).not_to have_text(other_log.name)
      end
    end

    context 'when the user has a number log' do
      before { expect(number_log).to be_present }

      let(:number_log) { user.logs.number.first! }

      context 'when the number log has at least one entry' do
        before { expect(number_log.log_entries).to exist }

        it 'shows a button to delete the most recent entry' do
          visit(log_path(slug: number_log.slug))

          expect(page).to have_button(delete_last_entry_text)
        end
      end
    end

    context 'when user has a text log' do
      let(:log) { user.logs.text.first! }

      context 'when there are no entries yet for the text log' do
        before { log.log_entries.find_each(&:destroy!) }

        it 'allows the user to submit log entries, edit them, and delete them' do
          visit(log_path(slug: log.slug))

          # Add first log entry
          first_log_entry_text = 'Some great text log entry content!'
          expect {
            first('.new-log-input textarea').native.send_keys(first_log_entry_text)
            click_on('Add')
            expect(page).to have_text(first_log_entry_text) # wait for AJAX request to complete
          }.to change {
            log.reload.log_entries.count
          }.by(1)

          last_log_entry = log.log_entries.reorder(:created_at).last!
          expect(last_log_entry.data).to eq(first_log_entry_text)

          # Add second log entry
          second_log_entry_text = 'Even more great content!'
          expect {
            first('.new-log-input textarea').native.send_keys(second_log_entry_text)
            click_on('Add')
            expect(page).to have_text(second_log_entry_text) # wait for AJAX request to complete
            expect(page).to have_text(first_log_entry_text) # confirm first log entry's still there
          }.to change {
            log.reload.log_entries.count
          }.by(1)

          last_log_entry = log.log_entries.reorder(:created_at).last!
          expect(last_log_entry.data).to eq(second_log_entry_text)

          # Edit second log entry (and verify that correct order is preserved)
          wait_for { page.find_all('button', text: 'Edit').size }.to eq(2)
          first('button', text: 'Edit').click
          added_edit_text = ' Added text!'
          expect(page).to have_css('.text-log-table textarea')
          first('.text-log-table textarea').send_keys(added_edit_text)
          first('button', text: 'Save').click
          expect(page).to have_text(
            /#{second_log_entry_text}#{added_edit_text}.*#{first_log_entry_text}/,
          )

          expect(page).not_to have_text(delete_last_entry_text)
          # Click the delete button for the oldest text log entry.
          page.find_all('button', text: /\ADelete\z/)[1].click
          expect(page).not_to have_text(first_log_entry_text)
        end
      end

      context 'when there is one entry for the log' do
        before { log.log_entries.drop(1).each(&:destroy!) }

        context 'when the log is not publicly viewable but has been shared with a certain email' do
          before do
            log.update!(publicly_viewable: false)
            log.log_shares.create!(email: other_user.email)
          end

          let(:other_user) { User.where.not(id: log.user_id).first! }

          context 'when the other user logs in' do
            before do
              Devise.sign_out_all_scopes
              sign_in(other_user)
            end

            it 'allows the sharee to view the log (via the appropriate URL)' do
              visit(user_shared_log_path(user_id: user.id, slug: log.slug))

              expect(page).to have_text(log.log_entries.first!.data)
            end
          end
        end
      end
    end

    context 'when a new log entry is published' do
      subject(:publish_new_log_entry) do
        # don't actually create the log entry, because we don't want the log entry to be returned
        # via an API call (by virtue of having been persisted to the database). we'll _only_ publish
        # the log entry via websockets (which requires stubbing `id` and `created_at` values).
        log_entry = log.log_entries.build(data: new_log_entry_text)
        expect(log_entry).
          to receive(:read_attribute_before_type_cast).
          with('created_at').
          and_return(Time.current)
        LogEntriesChannel.broadcast_to(
          log_entry.log,
          acting_browser_uuid: SecureRandom.uuid,
          action: 'created',
          model: LogEntrySerializer.new(log_entry).as_json.merge(
            id: LogEntries::TextLogEntry.maximum(:id) + 1,
          ),
        )
      end

      let(:new_log_entry_text) { SecureRandom.uuid }
      let(:log_policy_stub) { instance_double(LogPolicy) }
      let(:log) { user.logs.text.first! }

      before do
        expect(LogPolicy).to receive(:new).at_least(:once).and_return(log_policy_stub)

        # We need to stub a LogPolicy#index? call when loading the log's show page; return true.
        expect(log_policy_stub).to receive(:index?).ordered.and_return(true)
      end

      context 'when a user tries to subscribe to an unauthorized log entries websocket channel' do
        before do
          expect(log_policy_stub).to receive(:show?).at_least(:once) do
            # Have the authorization check fail for the `LogEntriesChannel`...
            if caller.any? { |file| file.include?('app/channels/log_entries_channel.rb') }
              false
            else
              # ...and pass otherwise (e.g. when requesting the log entries via the API endpoint)
              true
            end
          end
        end

        it 'does not render a new log entry that is broadcast to that channel' do
          visit(log_path(slug: log.slug))

          expect(page).to have_text(log.log_entries.first!.data)

          # Unfortunately, we need to sleep to give websockets/JavaScript enough time to put the new
          # log entry into the page. If we don't wait long enough for the new text to appear, then
          # this test can be a false positive (wrongly passing) / false negative (not failing).
          # Fortunately, a wait time of 1 second, which isn't too long, seems to be long enough to
          # make the test consitently fail if the code does the wrong thing.
          publish_new_log_entry
          sleep(1)
          expect(page).not_to have_text(new_log_entry_text)
        end
      end

      context 'when a user is authorized to subscribe to the log entries websocket channel' do
        before { expect(log_policy_stub).to receive(:show?).at_least(:once).and_return(true) }

        it 'renders a new log entry that is broadcast to that channel' do
          visit(log_path(slug: log.slug))

          expect(page).to have_text(log.log_entries.first!.data)

          publish_new_log_entry
          expect(page).to have_text(new_log_entry_text)
        end
      end
    end
  end
end
