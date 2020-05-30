# frozen_string_literal: true

class LogReminderMailer < ApplicationMailer
  def reminder(log_id)
    @log = Log.find(log_id)
    mail(subject: %(Submit a log entry for your "#{@log.name}" log))
  end
end
