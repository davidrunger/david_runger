# frozen_string_literal: true

class VoicemailsMailbox < ApplicationMailbox
  using ParsedMailBody

  def process
    if auth_token.blank?
      Rails.logger.info("No AuthToken could be found for email with subject '#{mail.subject}'")
      return
    end

    if voicemail_message_content.blank?
      Rails.logger.info("No voicemail message was found in email with subject '#{mail.subject}'")
      return
    end

    # If any errors occur here, we want to rescue them, so that the Sidekiq mail-processing job
    # won't retry (maybe sending text messages repeatedly, which costs $ and which annoys the user)
    begin
      SmsRecords::SendMessage.new(
        user: user,
        message_type: 'forwarded_voicemail',
        message_params: {
          subject: subject,
          voicemail_message_content: voicemail_message_content,
        },
      ).run!
    rescue => error
      Rollbar.error(
        error,
        user_id: user.id,
        subject: subject,
        voicemail_message_content: voicemail_message_content,
      )
    end
  end

  private

  def auth_token_secret
    mail.to.first.presence!.
      match(ApplicationMailbox::VOICEMAILS_ROUTING_REGEX)[:auth_token_secret]
  end

  def auth_token
    AuthToken.find_by(secret: auth_token_secret)
  end

  def user
    auth_token.user
  end

  def subject
    (mail.subject.presence || 'Incoming Voicemail').delete_prefix('Fwd: ')
  end

  def voicemail_message_content
    mail.parsed_body.
      match(%r{<https://voice.google.com> (?<message>.+) play message})&.
      named_captures&.
      dig('message')
  end
end
