class SendLogReminderEmails
  prepend ApplicationWorker

  unique_while_executing!

  def perform
    Log.needing_reminder.find_each do |log|
      delivery_limit =
        Email::UserGeneratedDeliveryLimiter.reserve_global(category: :log_reminder)

      unless delivery_limit.permitted?
        next
      end

      log.update!(reminder_last_sent_at: Time.current)
      LogReminderMailer.reminder(log.id).deliver_later
    end
  end
end
