# frozen_string_literal: true

class SendLogReminderEmails
  prepend ApplicationWorker

  def perform
    Log.needing_reminder.find_each do |log|
      log.update!(reminder_last_sent_at: Time.current)
      LogReminderMailer.reminder(log.id).deliver_later
    end
  end
end
