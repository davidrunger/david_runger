# frozen_string_literal: true

class ReplyForwardingMailer < ApplicationMailer
  def reply_received(from_email, subject, body)
    @from_email = from_email
    @subject = subject
    @body = body

    mail(
      to: '"David Runger" <davidjrunger@gmail.com>',
      from: '"DavidRunger.com" <noreply@davidrunger.com>',
      reply_to: nil,
      subject: "#{from_email} wrote: #{subject}",
    )
  end
end
