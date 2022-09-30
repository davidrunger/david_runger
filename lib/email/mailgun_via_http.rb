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
      response =
        connection.post(
          MESSAGES_PATH,
          {
            to: mail['To'].to_s,
            subject: mail['Subject'].to_s,
            from: mail['From'].to_s,
            'h:Reply-To' => mail['Reply-To'].to_s,
            html: mail.body.to_s.presence || '<div></div>', # Mailgun requires us to send something
          }.compact,
        )

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
