class LogEntriesMailbox < ApplicationMailbox
  using Refinements::ParsedMailBody

  def process
    email_submission_token =
      mail.to.first.presence!.match(ApplicationMailbox::LOG_ENTRIES_ROUTING_REGEX)[:email_submission_token]
    user = User.find_by(email: mail.from&.first)
    log = user&.logs&.find_by(email_submission_token:)

    unless log
      return
    end

    LogEntries::Save.new(log_entry: log.build_log_entry_with_datum(data: mail.parsed_body)).run
  end
end
