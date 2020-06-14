# frozen_string_literal: true

class SmsRecords::PostToNexmo < ApplicationAction
  requires :message_body, String
  requires :phone_number, String

  returns :nexmo_response, HTTParty::Response

  def execute
    if ENV['NEXMO_API_KEY'].present?
      send_via_nexmo!
    else
      # print message to facilitate debugging (e.g. particularly in development)
      log_message
    end
  end

  private

  def send_via_nexmo!
    result.nexmo_response = NexmoClient.send_text!(number: phone_number, message: message_body)
  end

  def log_message
    puts(<<~LOG)
      NEXMO_API_KEY is blank; message would have been:
      ~~~~~~~~~~~~~~~~~~~~~
      #{message_body}
      =====================
    LOG
  end
end
