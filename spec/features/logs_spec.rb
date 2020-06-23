# frozen_string_literal: true

RSpec.describe 'Logs app' do
  let(:user) { users(:user) }

  context 'when user is signed in' do
    before { sign_in(user) }

    it 'renders the logs app and allows the user to view a log' do
      visit logs_path

      expect(page).to have_text(user.email)
      user.logs.pluck(:name).presence!.each do |log_name|
        expect(page).to have_text(log_name)
      end
      expect(page).to have_text('Create new log')

      log = user.logs.first!
      click_link(log.name)
      expect(page).to have_current_path("/logs/#{log.slug}")
    end

    context 'when user has a text log' do
      let(:log) { user.logs.text.first! }

      context 'when there are no entries yet for the text log' do
        before { log.log_entries.find_each(&:destroy!) }

        it 'allows the user to submit their first and second entry for the log' do
          visit(log_path(slug: log.slug))

          first_log_entry_text = 'Some great text log entry content!'
          expect {
            first(:css, '.new-log-input textarea').native.send_keys(first_log_entry_text)
            click_button('Add')
            expect(page).to have_text(first_log_entry_text) # wait for AJAX request to complete
          }.to change {
            log.reload.log_entries.count
          }.by(1)

          last_log_entry = log.log_entries.reorder(:created_at).last!
          expect(last_log_entry.data).to eq(first_log_entry_text)

          second_log_entry_text = 'Even more great content!'
          expect {
            first(:css, '.new-log-input textarea').native.send_keys(second_log_entry_text)
            click_button('Add')
            expect(page).to have_text(second_log_entry_text) # wait for AJAX request to complete
            expect(page).to have_text(first_log_entry_text) # confirm first log entry's still there
          }.to change {
            log.reload.log_entries.count
          }.by(1)

          last_log_entry = log.log_entries.reorder(:created_at).last!
          expect(last_log_entry.data).to eq(second_log_entry_text)
        end
      end
    end

    context 'when a user tries to subscribe to an unauthorized log entries websocket channel' do
      before do
        expect(LogPolicy).to receive(:new).at_least(:once).and_return(log_policy_stub)

        # We need to stub a LogPolicy#index? call when loading the log's show page; return true.
        expect(log_policy_stub).to receive(:index?).ordered.and_return(true)

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

      let(:log_policy_stub) { instance_double(LogPolicy) }
      let(:log) { user.logs.text.first! }

      it 'does not render new log entries that are broadcast to that channel' do
        visit(log_path(slug: log.slug))

        expect(page).to have_text(log.log_entries.first!.data)

        new_log_entry_text = SecureRandom.uuid
        expect(LogEntriesChannel).to receive(:broadcast_to).and_call_original
        LogEntries::Save.new(log_entry: log.log_entries.build(data: new_log_entry_text)).execute

        # Unfortunately, we need to sleep to give websockets/JavaScript enough time to put the new
        # log entry into the page. If we don't wait long enough for the new text to appear, then
        # this test can be a false positive (wrongly passing) / false negative (not failing).
        # Fortunately, a wait time of 1 second, which isn't too long, seems to be long enough to
        # make the test consitently fail if the code does the wrong thing.
        sleep(1)
        expect(page).not_to have_text(new_log_entry_text)
      end
    end
  end
end
