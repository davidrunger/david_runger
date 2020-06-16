# frozen_string_literal: true

class SmsRecords::SendMessage < ApplicationAction
  class SaveSmsRecordError < StandardError ; end

  requires :message_params, Hash
  requires :message_type, String
  requires :user, User do
    validates :phone, presence: true
  end

  fails_with :nexmo_request_failed

  def execute
    message_body =
      SmsRecords::GenerateMessage.new(
        message_params: message_params,
        message_type: message_type,
        user: user,
      ).run!.message_body

    nexmo_response =
      SmsRecords::PostToNexmo.new(
        message_body: message_body,
        phone_number: user.phone,
      ).run!.nexmo_response

    if nexmo_response.success?
      SmsRecords::SaveSmsRecord.new(
        nexmo_response: nexmo_response,
        user: user,
      ).run!
    else
      result.nexmo_request_failed!
    end
  end
end
