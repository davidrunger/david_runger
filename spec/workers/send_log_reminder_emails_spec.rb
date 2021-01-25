# frozen_string_literal: true

RSpec.describe SendLogReminderEmails do
  subject(:worker) { SendLogReminderEmails.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    context 'when there is at least one log that is due to have a reminder email sent' do
      let(:log_needing_reminder) { Log.needing_reminder.first! }

      before do
        log = Log.number.joins(:log_entries).first!
        log.update!(
          reminder_time_in_seconds: 3600,
          reminder_last_sent_at: nil,
        )
        log.log_entries.find_each { _1.update!(created_at: 2.hours.ago) }
      end

      around do |spec|
        freeze_time
        spec.run
        travel_back
      end

      it 'updates the reminder_last_sent_at timestamp (making the log no longer need reminding)' do
        expect(Log.needing_reminder).to include(log_needing_reminder)

        expect { perform }.to change {
          log_needing_reminder.reload.reminder_last_sent_at
        }.to(Time.current)

        expect(Log.needing_reminder).not_to include(log_needing_reminder)
      end

      it 'sends a LogReminderMailer#reminder email for the log', queue_adapter: :test do
        expect { perform }.to enqueue_mail(LogReminderMailer, :reminder).
          with(args: [log_needing_reminder.id])
      end
    end
  end
end
