# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
module Email
  class MailgunViaHttp
    MAILGUN_URL = 'https://api.mailgun.net/v3/mg.davidrunger.com'
    # must _not_ start with a slash! ( https://github.com/lostisland/faraday/issues/293/ )
    MESSAGES_PATH = 'messages'

    attr_accessor :message

    # rubocop:disable Lint/UselessMethodDefinition, Lint/RedundantCopDisableDirective
    # rubocop:disable Style/RedundantInitialize
    def initialize(_mail) ; end
    # rubocop:enable Style/RedundantInitialize
    # rubocop:enable Lint/UselessMethodDefinition, Lint/RedundantCopDisableDirective

    def deliver!(mail)
      post_body = {
        to: mail['To'].to_s,
        subject: mail['Subject'].to_s,
        from: mail['From'].to_s,
        'h:Reply-To' => mail['Reply-To'].to_s,
        html: mail.body.to_s.presence || mail.html_part&.body.presence || '<div></div>',
      }

      if mail.has_attachments?
        post_body[:attachment] = []
        # use random directory for thread safety (so users' emails don't conflict w/ each other)
        directory = "tmp/attachments/#{Time.zone.today.iso8601}/#{SecureRandom.alphanumeric(5)}"
        FileUtils.mkdir_p(directory)
        mail.attachments.each do |attachment|
          file = File.new("#{directory}/#{attachment.filename}", 'w+b')
          file.write(attachment.body.to_s)
          file.rewind
          post_body[:attachment] <<
            Faraday::Multipart::FilePart.new(file, 'application/octet-stream')
        end
      end

      response = connection.post(MESSAGES_PATH, post_body)

      if Flipper.enabled?(:log_mailgun_http_response)
        Rails.logger.info(<<~LOG.squish)
          Mailgun response for email to #{mail['To']} with subject "#{mail['Subject']}":
          status=#{response.status}
          body=#{response.body}
          headers=#{response.headers}.
        LOG
      end
    end

    private

    def connection
      Faraday.new(MAILGUN_URL) do |conn|
        conn.request(:multipart)
        conn.request(:url_encoded)
        conn.request(
          :authorization,
          :basic,
          'api',
          Rails.application.credentials.mailgun!.fetch(:api_key),
        )
      end
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
