# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
module Email
  class MailgunViaHttp
    extend Memoist

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
      response = connection.post(MESSAGES_PATH, post_body(mail))

      if Flipper.enabled?(:log_mailgun_http_response)
        Rails.logger.info(<<~LOG.squish)
          Mailgun response for email to #{mail['To']} with subject "#{mail['Subject']}":
          status=#{response.status}
          body=#{response.body}
          headers=#{response.headers}.
        LOG
      end

      delete_attachments
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
          Rails.application.credentials.mailgun!.fetch(:api_key),
        )
      end
    end

    memoize \
    def attachments_tmp_directory
      # use random directory for thread safety (so users' emails don't conflict w/ each other)
      "tmp/attachments/#{Time.zone.today.iso8601}/#{SecureRandom.alphanumeric(5)}"
    end

    memoize \
    def post_body(mail)
      body = {
        to: mail['To'].to_s,
        subject: mail['Subject'].to_s,
        from: mail['From'].to_s,
        'h:Reply-To' => mail['Reply-To'].to_s,
        html: mail.body.to_s.presence || '<div></div>',
      }

      if mail.has_attachments?
        body[:attachment] = []
        FileUtils.mkdir_p(attachments_tmp_directory)
        mail.attachments.each do |attachment|
          file = File.new("#{attachments_tmp_directory}/#{attachment.filename}", 'w+b')
          file.write(attachment.body.to_s)
          file.rewind
          body[:attachment] <<
            Faraday::Multipart::FilePart.new(file, 'application/octet-stream')
        end
      end

      body
    end

    def delete_attachments
      FileUtils.rm_rf(attachments_tmp_directory)
      nil
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
