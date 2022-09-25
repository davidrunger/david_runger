# frozen_string_literal: true

class RepliesMailbox < ApplicationMailbox
  using ParsedMailBody

  def process
    from_email = mail['From'].to_s.presence!
    subject = mail.subject.presence || '[no subject]'
    is_attachment = mail.attachment?
    has_attachments = mail.has_attachments?
    mail.without_attachments!
    body =
      begin
        if is_attachment
          '[no body (just an attachment)]'
        else
          mail.parsed_body || '[no body]'
        end
      rescue => error
        Rollbar.error(
          error,
          from_email:,
          subject:,
          body: ((mail.text_part.presence || mail.body).to_s.dup rescue '[error reading raw body]'),
        )
        '[error reading parsed body]'
      end

    ReplyForwardingMailer.reply_received(
      mail.message_id,
      from_email,
      subject,
      body,
      is_attachment,
      has_attachments,
    ).deliver_later
  end
end
