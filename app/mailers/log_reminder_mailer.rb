# frozen_string_literal: true

class LogReminderMailer < ApplicationMailer
  def reminder(log_id)
    @log = Log.includes(:user).find(log_id)
    mail(
      to: @log.user.email,
      subject: %(Submit a log entry for your "#{@log.name}" log),
      from: %("DavidRunger.com" <log-reminders@davidrunger.com>),
      # ApplicationMailbox::LOG_ENTRIES_ROUTING_REGEX depends on the format of this `reply_to`
      reply_to: %("#{@log.name} Log Entries" <log-entries|log/#{@log.id}@mg.davidrunger.com>),
    )
  end
end
