# frozen_string_literal: true

class LogEntriesMailbox < ApplicationMailbox
  def process
    log_id = mail.to.first.presence!.match(ApplicationMailbox::LOG_ENTRIES_ROUTING_REGEX)[:log_id]
    user_email = mail.from.first.presence!
    user = User.find_by!(email: user_email)
    log = user.logs.find(log_id)
    email_content =
      # call #dup because #trim modifies the string (via at least one `#gsub!` call)
      EmailReplyTrimmer.trim((mail.text_part.presence || mail.body).to_s.dup).
        sub(/\A[\s\S]*^Content-Transfer-Encoding:.+\n+/, '').
        rstrip

    log.log_entries.create!(data: email_content)
  end
end
