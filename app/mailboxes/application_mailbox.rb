# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  LOG_REMINDER_REPLIES_ROUTING_REGEX = /log-reminders\+(?<slug>.+)@davidrunger\.com/i.freeze

  routing(
    LOG_REMINDER_REPLIES_ROUTING_REGEX => :log_reminder_replies,
  )
end
