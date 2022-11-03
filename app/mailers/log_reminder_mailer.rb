# frozen_string_literal: true

class LogReminderMailer < ApplicationMailer
  def reminder(log_id)
    @log = Log.find(log_id)
    log_name = @log.name
    mail(
      to: @log.user.email,
      subject: %(Submit a log entry for your "#{log_name}" log),
      from: %("DavidRunger.com" <log-reminders@davidrunger.com>),
      # ApplicationMailbox::LOG_ENTRIES_ROUTING_REGEX depends on the format of this `reply_to`
      reply_to: %("#{log_name} Log Entries" <log-entries|log/#{@log.id}@mg.davidrunger.com>),
    )
  end
end
