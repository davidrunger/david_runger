# frozen_string_literal: true

class ReplyForwardingMailer < ApplicationMailer
  def reply_received(message_id, from_email, subject, body, has_attachments)
    @from_email = from_email
    @subject = subject
    @body = body

    if has_attachments
      inbound_email = ActionMailbox::InboundEmail.find_by!(message_id:)
      inbound_email_attachments = Mail.new(inbound_email.raw_email_blob.download).attachments
      inbound_email_attachments.each do |attachment|
        attachments[attachment.filename] = attachment.decoded
      end
    end

    mail(
      to: '"David Runger" <davidjrunger@gmail.com>',
      from: '"DavidRunger.com" <noreply@davidrunger.com>',
      reply_to: nil,
      subject: "#{from_email} wrote: #{subject}",
    )
  end
end
