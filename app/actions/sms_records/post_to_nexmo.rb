# frozen_string_literal: true

class SmsRecords::PostToNexmo < ApplicationAction
  requires :message_body, String, presence: true
  requires :phone_number, String, presence: true

  returns :nexmo_response_data, Hash

  fails_with :nexmo_request_failed

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
    response = NexmoClient.send_text!(number: phone_number, message: message_body)
    if response.success?
      result.nexmo_response_data = response.body
    else
      result.nexmo_request_failed!
    end
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
