# frozen_string_literal: true

class RepliesMailbox < ApplicationMailbox
  using ParsedMailBody

  def process
    from_email = mail['From'].to_s.presence!
    subject = mail.subject.presence || '[no subject]'
    body = mail.parsed_body || '[no body]'

    ReplyForwardingMailer.reply_received(from_email, subject, body).deliver_later
  end
end
