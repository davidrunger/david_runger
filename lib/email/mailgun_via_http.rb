# rubocop:disable-next Style/ClassAndModuleChildren
module Email
  class MailgunViaHttp
    prepend Memoization

    DEVELOPER_EMAILS = Set['davidjrunger@gmail.com'].freeze
    MAILGUN_URL = 'https://api.mailgun.net/v3/mg.davidrunger.com'
    # must _not_ start with a slash! ( https://github.com/lostisland/faraday/issues/293/ )
    MESSAGES_PATH = 'messages'

    # rubocop:disable Lint/UselessMethodDefinition, Lint/RedundantCopDisableDirective
    # rubocop:disable-next Style/RedundantInitialize
    def initialize(_mail) ; end
    # rubocop:enable Lint/UselessMethodDefinition, Lint/RedundantCopDisableDirective

    def deliver!(mail)
      response = connection.post(MESSAGES_PATH, post_body(mail))

      if Flipper.enabled?(:log_mailgun_http_response)
        Rails.logger.info(<<~LOG.squish)
          Mailgun response for email to #{mail['To']} with subject "#{mail['Subject']}":
          status=#{response.status}
          body=#{response.body}
          headers=#{response.headers}.
        LOG
      end

      nil
    end

    private

    memoize \
    def connection
      Faraday.new(MAILGUN_URL) do |conn|
        conn.request(:multipart)
        conn.request(:url_encoded)
        conn.request(
          :authorization,
          :basic,
          'api',
          ENV.fetch('MAILGUN_API_KEY'),
        )
      end
    end

    memoize \
    def post_body(mail)
      body = {
        to: safe_to_value(mail),
        subject: mail['Subject'].to_s,
        from: mail['From'].to_s,
        'h:Reply-To' => mail['Reply-To'].to_s,
        html: mail.body.to_s.presence || '<div></div>',
      }

      if mail.has_attachments?
        body[:attachment] = mail.attachments.map { |attachment| file_part(attachment) }
      end

      body
    end

    def file_part(attachment)
      Faraday::Multipart::FilePart.new(
        StringIO.new(attachment.body.to_s),
        'application/octet-stream',
        AttachmentFilename.sanitize(attachment.filename),
      )
    end

    def safe_to_value(mail)
      mail_to = mail['To']
      to_string = mail_to.to_s
      if Rails.env.development?
        recipients = mail_to.field.addresses
        if Set[*recipients].subset?(DEVELOPER_EMAILS)
          to_string
        else
          fail("You *actually* tried to send an email to #{recipients}!")
        end
      else
        to_string
      end
    end
  end
end
