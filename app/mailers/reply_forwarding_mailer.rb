# frozen_string_literal: true

class ReplyForwardingMailer < ApplicationMailer
  # rubocop:disable Metrics/ParameterLists
  def reply_received(message_id, from_email, subject, body, is_attachment, has_attachments)
    @from_email = from_email
    @subject = subject
    @body = body

    if is_attachment || has_attachments
      inbound_email = ActionMailbox::InboundEmail.find_by!(message_id:)

      if is_attachment
        inbound_email_mail = Mail.new(inbound_email.raw_email_blob.download)
        attachments[inbound_email_mail.filename] = inbound_email_mail.decoded
      end

      if has_attachments
        inbound_email_attachments = Mail.new(inbound_email.raw_email_blob.download).attachments
        inbound_email_attachments.each do |attachment|
          attachments[attachment.filename] = attachment.decoded
        end
      end
    end

    mail(
      from: '"DavidRunger.com" <noreply@davidrunger.com>',
      reply_to: nil,
      subject: "#{from_email} wrote: #{subject}",
    )
  end
  # rubocop:enable Metrics/ParameterLists
end
