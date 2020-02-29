# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
module Email
  class MailgunViaHttparty
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
          subject: mail.subject,
          html: mail.body.to_s,
        },
      )
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
