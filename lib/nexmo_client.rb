# frozen_string_literal: true

module NexmoClient
  NEXMO_SMS_API_URL = 'https://rest.nexmo.com/sms/json'.freeze

  def self.send_text!(number:, message:)
    HTTParty.post(
      NEXMO_SMS_API_URL,
      body: {
        text: message,
        to: number,
        from: ENV['NEXMO_PHONE_NUMBER'],
        api_key: ENV['NEXMO_API_KEY'],
        api_secret: ENV['NEXMO_API_SECRET'],
      },
    )
  end
end
