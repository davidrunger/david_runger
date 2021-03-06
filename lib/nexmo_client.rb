# frozen_string_literal: true

module NexmoClient
  NEXMO_SMS_API_URL = 'https://rest.nexmo.com/sms/json'

  def self.send_text!(number:, message:)
    Faraday.json_connection.post(
      NEXMO_SMS_API_URL,
      {
        text: message,
        to: number,
        from: ENV.fetch('NEXMO_PHONE_NUMBER'),
        api_key: ENV.fetch('NEXMO_API_KEY'),
        api_secret: ENV.fetch('NEXMO_API_SECRET'),
      },
    )
  end
end
