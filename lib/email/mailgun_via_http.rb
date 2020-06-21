# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
module Email
  class MailgunViaHttp
    # must _not_ start with a slash! ( https://github.com/lostisland/faraday/issues/293/ )
    MESSAGES_PATH = 'messages'

    attr_accessor :message

    def initialize(_mail) ; end

    def deliver!(mail)
      connection.post(
        MESSAGES_PATH,
        {
          to: mail['To'].to_s,
          subject: mail['Subject'].to_s,
          from: mail['From'].to_s,
          'h:Reply-To' => mail['Reply-To'].to_s,
          html: mail.body.to_s,
        }.compact,
      )
    end

    private

    def connection
      Faraday.new(ENV['MAILGUN_URL']) do |conn|
        conn.request(:url_encoded)
        conn.basic_auth('api', ENV['MAILGUN_API_KEY'])
      end
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
