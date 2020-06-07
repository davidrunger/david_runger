# frozen_string_literal: true

class LogEntriesMailbox < ApplicationMailbox
  extend Memoist

  def process
    if debug?
      puts('--- BEGIN mail.text_part.presence.to_s')
      p(mail.text_part.presence.to_s)
      puts('--- END mail.text_part.presence.to_s')

      puts('--- BEGIN mail.body.to_s')
      p(mail.body.to_s)
      puts('--- END mail.body.to_s')
    end

    log_id = mail.to.first.presence!.match(ApplicationMailbox::LOG_ENTRIES_ROUTING_REGEX)[:log_id]
    user_email = mail.from.first.presence!
    user = User.find_by!(email: user_email)
    log = user.logs.find(log_id)
    email_content =
      # call #dup because #trim modifies the string (via at least one `#gsub!` call)
      EmailReplyTrimmer.trim((mail.text_part.presence || mail.body).to_s.dup).
        sub(/\AContent-Type:.+\n+/, '').
        rstrip

    if debug?
      puts('--- BEGIN email_content')
      p(email_content)
      puts('--- END email_content')
    end

    log.log_entries.create!(data: email_content)
  end

  private

  memoize \
  def debug?
    Flipper.enabled?(:debug_log_entries_mailbox_processing)
  end
end
