# frozen_string_literal: true

class LogEntriesMailbox < ApplicationMailbox
  using ParsedMailBody

  def process
    log_id = mail.to.first.presence!.match(ApplicationMailbox::LOG_ENTRIES_ROUTING_REGEX)[:log_id]
    user_email = mail.from.first.presence!
    user = User.find_by!(email: user_email)
    log = user.logs.find(log_id)

    log.log_entries.create!(data: mail.parsed_body)
  end
end
