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

    post_to_nexmo_result =
      SmsRecords::PostToNexmo.new(
        message_body: message_body,
        phone_number: user.phone,
      ).run!

    if post_to_nexmo_result.success?
      SmsRecords::SaveSmsRecord.new(
        nexmo_response_data: post_to_nexmo_result.nexmo_response_data,
        user: user,
      ).run!
    elsif post_to_nexmo_result.nexmo_request_failed?
      result.nexmo_request_failed!
    end
  end
end
