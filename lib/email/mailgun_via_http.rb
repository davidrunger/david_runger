# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
module Email
  class MailgunViaHttp
    attr_accessor :message

    def initialize(_mail) ; end

    def deliver!(mail)
      HTTParty.post(
        "#{ENV['MAILGUN_URL']}/messages",
        basic_auth: {
          username: 'api',
          password: ENV['MAILGUN_API_KEY'],
        },
        body: {
          from: mail['From'].to_s,
          to: mail['To'].to_s,
          subject: mail['Subject'].to_s,
          html: mail.body.to_s,
          'h:Reply-To' => mail['Reply-To'].to_s,
        }.compact,
      )
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
