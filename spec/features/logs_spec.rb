RSpec.describe 'Logs app' do
  let(:user) { users(:user) }

  context 'when a user is signed in' do
    before { sign_in(user) }

    let(:delete_last_entry_text) { 'Delete last entry' }

    context 'when user has at least one log' do
      let(:log) { user.logs.first! }

      describe 'aspects of the view pertaining to sharing or not sharing' do
        before do
          visit(page_path)
        end

        let(:shared_by_text) { "shared by #{user.email}" }
        let(:log_control_text_fragments) do
          [
            delete_last_entry_text,
            'Sharing settings',
            'Reminder settings',
            'Delete log',
            'open the log selector',
          ]
        end

        context 'when user is not viewing a log sharing preview' do
          let(:page_path) { log_path(slug: log.slug) }

          it 'does not mention the email of the sharing user and shows log control buttons' do
            expect(page).not_to have_text(shared_by_text)

            log_control_text_fragments.each do |log_control_text_fragment|
              expect(page).to have_text(log_control_text_fragment)
            end
          end
        end

        context 'when user views a log sharing preview' do
          let(:page_path) { user_shared_log_path(user_id: user.id, slug: log.slug) }

          it 'mentions the email of the sharing user and does not show log control buttons' do
            expect(page).to have_text(shared_by_text)

            log_control_text_fragments.each do |log_control_text_fragment|
              expect(page).not_to have_text(log_control_text_fragment)
            end
          end
        end
      end
    end

    context 'when user has multiple logs' do
      before { expect(user.logs.size).to be >= 2 }

      it 'renders the logs app and allows the user to view a log' do
        visit logs_path

        expect(page).to have_text(user.email)
        user.logs.pluck(:name).presence!.each do |log_name|
          expect(page).to have_text(log_name)
        end
        expect(page).to have_text('New Log')

        # Check for (platform-specific) keyboard shortcut to open log-selector modal.
        expect(page).to have_text('Tip: Ctrl+K will open the log selector.')

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

        it 'allows the user to delete the most recent entry' do
          visit(log_path(slug: number_log.slug))

          most_recent_log_entry =
            number_log.log_entries.reorder(:created_at).last!

          expect {
            click_on(delete_last_entry_text)
            within('.el-popconfirm') do
              click_on('Yes')
            end
          }.to change {
            LogEntry.find_by(id: most_recent_log_entry.id)
          }.from(LogEntry).to(nil)
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
            expect(page).to have_text(second_log_entry_text) # Wait for AJAX request to complete.
            expect(page).to have_text(first_log_entry_text) # Confirm first log entry's still there.
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

          # Make sure that we don't have a "Delete last entry button" (which is for graph logs).
          expect(page).not_to have_text(delete_last_entry_text)

          # Click the delete button for the oldest text log entry (listed second on the page).
          page.find_all('button', text: /\ADelete\z/)[1].click
          within('.el-popconfirm') do
            click_on('Yes')
          end
          expect(page).not_to have_text(first_log_entry_text)
        end
      end

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

          it 'allows the sharee to view the log entries (via the appropriate URL)' do
            visit(user_shared_log_path(user_id: user.id, slug: log.slug))

            log.log_entries.each do |log_entry|
              expect(page).to have_text(log_entry.data)
            end
          end
        end
      end

      context 'when there are multiple entries for the log' do
        before do
          (2 - log.log_entries.size).times do
            log.build_log_entry_with_datum(
              data: "Scary dream #{SecureRandom.alphanumeric(5)}!",
            ).save!
          end
        end

        it 'allows the user to download a CSV with the log data' do
          visit(log_path(slug: log.slug))

          csv_glob = Capybara.save_path.join('*.csv')
          Rails.root.glob(csv_glob).each { FileUtils.rm(it) }

          click_on('Download CSV')

          wait_for { Rails.root.glob(csv_glob) }.to be_present

          downloaded_csv_path = Rails.root.glob(csv_glob).last
          csv = CSV.read(downloaded_csv_path, headers: true)

          expect(csv.headers).to eq(['Time', log.data_label])

          log.
            log_entries.
            includes(:log_entry_datum).
            reorder(created_at: :desc).
            each_with_index do |log_entry, index|
              row = csv[index]
              expect(row['Time']).to eq(log_entry.created_at.utc.iso8601)
              expect(row[log.data_label]).to eq(log_entry.data)
            end
        end
      end
    end

    context 'when a new log entry is published' do
      subject(:publish_new_log_entry) do
        # Don't actually create the log entry, because we don't want the log entry to be returned
        # via an API call (by virtue of having been persisted to the database). We'll _only_ publish
        # the log entry via websockets (which requires stubbing `id` and `created_at` values).
        log_entry = log.build_log_entry_with_datum(data: new_log_entry_text)
        expect(log_entry).
          to receive(:read_attribute_before_type_cast).
          with('created_at').
          and_return(Time.current)
        LogEntriesChannel.broadcast_to(
          log_entry.log,
          acting_browser_uuid: SecureRandom.uuid,
          action: 'created',
          model: LogEntrySerializer.new(log_entry).as_json.merge(
            id: LogEntry.maximum(:id) + 1,
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

          # Unfortunately, we need to sleep to give WebSockets/JavaScript enough
          # time to put the new log entry into the page. If we don't wait long
          # enough for the new text to appear, then this test can be a false
          # negative (not failing). A wait time of 1 second seems to be long
          # enough to make the test consistently fail if this is broken.
          publish_new_log_entry
          sleep(0.5)

          expect(page).not_to have_text(new_log_entry_text)
        end
      end

      context 'when a user is authorized to subscribe to the log entries websocket channel' do
        before { expect(log_policy_stub).to receive(:show?).at_least(:once).and_return(true) }

        it 'renders a new log entry that is broadcast to that channel' do
          visit(log_path(slug: log.slug))

          expect(page).to have_text(log.log_entries.first!.data)

          wait_for do
            page.evaluate_script('window.davidrunger?.connectedToLogEntriesChannel')
          end.to eq(true)

          sleep(0.5) # Give JavaScript even more time to be ready to receive WebSocket events.

          publish_new_log_entry

          expect(page).to have_text(new_log_entry_text)
        end
      end
    end
  end
end
