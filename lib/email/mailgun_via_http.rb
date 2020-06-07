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
          from: mail.from.first,
          to: mail.to.first,
          subject: mail.subject,
          html: mail.body.to_s,
          'h:Reply-To' => mail.reply_to.first,
        }.compact,
      )
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
