# frozen_string_literal: true

class SmsRecords::SaveSmsRecord < ApplicationAction
  requires :nexmo_response, HTTParty::Response
  requires :user, User

  def execute
    create_records_from_httparty_response(response: nexmo_response, user: user)
  end

  private

  def create_records_from_httparty_response(response:, user:)
    messages = response.parsed_response['messages']
    messages.presence!.each do |message_hash|
      user.sms_records.create!(nexmo_message_hash_to_attributes(message_hash))
    end
  end

  def nexmo_message_hash_to_attributes(message_hash)
    {
      cost: Float(message_hash['message-price']),
      error: message_hash['error-text'],
      nexmo_id: message_hash['message-id'],
      status: message_hash['status'],
      to: message_hash['to'],
    }
  end
end
