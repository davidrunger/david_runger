# frozen_string_literal: true

class LogEntriesMailbox < ApplicationMailbox
  using ParsedMailBody

  def process
    log_id = mail.to.first.presence!.match(ApplicationMailbox::LOG_ENTRIES_ROUTING_REGEX)[:log_id]
    user_email = mail.from.first.presence!
    user = User.find_by!(email: user_email)
    log = user.logs.find(log_id)

    LogEntries::Create.new(log: log, attributes: { value: mail.parsed_body }).run!
  end
end
