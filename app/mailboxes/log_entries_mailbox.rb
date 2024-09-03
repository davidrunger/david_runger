class LogEntriesMailbox < ApplicationMailbox
  using Refinements::ParsedMailBody

  def process
    log_id = mail.to.first.presence!.match(ApplicationMailbox::LOG_ENTRIES_ROUTING_REGEX)[:log_id]
    user_email = mail.from.first.presence!
    user = User.find_by!(email: user_email)
    log = user.logs.find(log_id)

    LogEntries::Save.new(log_entry: log.build_log_entry_with_datum(data: mail.parsed_body)).run
  end
end
