# frozen_string_literal: true

class LogReminderMailer < ApplicationMailer
  def reminder(log_id)
    @log = Log.find(log_id)
    mail(
      to: @log.user.email,
      # ApplicationMailbox::LOG_REMINDER_REPLIES_ROUTING_REGEX depends on the format of this `from`
      from: %("DavidRunger.com" <log-reminders+#{@log.slug}@davidrunger.com>),
      subject: %(Submit a log entry for your "#{@log.name}" log),
    )
  end
end
