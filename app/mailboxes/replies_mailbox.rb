# frozen_string_literal: true

class RepliesMailbox < ApplicationMailbox
  using ParsedMailBody

  def process
    from_email = mail['From'].to_s.presence!
    subject = mail.subject.presence || '[no subject]'
    body =
      begin
        mail.parsed_body || '[no body]'
      rescue => error
        Rollbar.error(
          error,
          from_email:,
          subject:,
          body: ((mail.text_part.presence || mail.body).to_s.dup rescue '[error reading raw body]'),
        )
        '[error reading parsed body]'
      end

    ReplyForwardingMailer.reply_received(from_email, subject, body).deliver_later
  end
end
