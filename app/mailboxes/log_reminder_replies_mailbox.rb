# frozen_string_literal: true

class LogReminderRepliesMailbox < ApplicationMailbox
  def process
    slug =
      mail.to.first.presence!.
        match(ApplicationMailbox::LOG_REMINDER_REPLIES_ROUTING_REGEX)[:slug]
    user_email = mail.from.first.presence!
    user = User.find_by!(email: user_email)
    log = user.logs.find_by!(slug: slug)
    log.log_entries.create!(data: mail.body.to_s.rstrip)
  end
end
