# frozen_string_literal: true

class LogReminderMailer < ApplicationMailer
  def reminder(log_id)
    @log = Log.find(log_id)
    log_name = @log.name
    mail(
      to: @log.user.email,
      subject: %(Submit a log entry for your "#{log_name}" log),
      from: email_address_with_name('log-reminders@davidrunger.com', 'DavidRunger.com'),
      # ApplicationMailbox::LOG_ENTRIES_ROUTING_REGEX depends on the format of this `reply_to`
      reply_to: email_address_with_name(
        "log-entries|log/#{@log.id}@mg.davidrunger.com",
        "#{log_name} Log Entries",
      ),
    )
  end
end
