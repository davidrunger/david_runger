# frozen_string_literal: true

class SmsRecords::SendMessage < ApplicationAction
  class InvalidMessageType < StandardError ; end
  class SaveSmsRecordError < StandardError ; end

  requires :message_params, Hash
  requires :message_type, String
  requires :user, User do
    validates :phone, presence: true
  end

  fails_with :nexmo_request_failed

  def execute
    if ENV['NEXMO_API_KEY'].present?
      send_via_nexmo!
    else
      log_message
    end
  end

  private

  def send_via_nexmo!
    nexmo_response = NexmoClient.send_text!(number: user.phone, message: message_body)
    if nexmo_response.success?
      save_sms_record(nexmo_response)
    else
      result.nexmo_request_failed!
    end
  end

  def log_message
    message_body # memoize `message_body` so that ActiveRecord queries don't get logged below
    # print message to facilitate debugging (e.g. particularly in development)
    puts(<<~LOG)
      NEXMO_API_KEY is blank; message would have been:
      ~~~~~~~~~~~~~~~~~~~~~
      #{message_body}
      =====================
    LOG
  end

  def grocery_store_items_needed_message_body
    store = user.stores.find(message_params['store_id'])
    ApplicationController.render(
      'sms_messages/grocery_list',
      layout: nil,
      locals: { store: store },
    ).rstrip
  end

  memoize \
  def message_body
    case message_type
    when 'grocery_store_items_needed' then grocery_store_items_needed_message_body
    else fail InvalidMessageType, "`#{message_type}` is not a valid message type"
    end
  end

  def save_sms_record(nexmo_response)
    saved_record_successfully =
      SmsRecord.create_records_from_httparty_response(response: nexmo_response, user: user)

    if !saved_record_successfully
      Rails.logger.error(<<~LOG.squish)
        Failed to create SmsRecord(s),
        user=#{user&.id}, message_type=#{message_type}, message_params=#{message_params}
      LOG
      Rollbar.error(
        SaveSmsRecordError.new,
        user: user&.id,
        message_type: message_type,
        message_params: message_params,
      )
    end
  end
end
