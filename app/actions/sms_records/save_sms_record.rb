# frozen_string_literal: true

class SmsRecords::SaveSmsRecord < ApplicationAction
  requires(
    :nexmo_response_data,
    {
      'message-count' => String,
      'messages' => [Hash],
    },
  )
  requires :user, User

  def execute
    nexmo_response_data['messages'].presence!.each do |message_hash|
      user.sms_records.create!(
        cost: Float(message_hash['message-price']),
        error: message_hash['error-text'],
        nexmo_id: message_hash['message-id'],
        status: message_hash['status'],
        to: message_hash['to'],
      )
    end
  end
end
