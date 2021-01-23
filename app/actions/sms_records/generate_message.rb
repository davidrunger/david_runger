# frozen_string_literal: true

class SmsRecords::GenerateMessage < ApplicationAction
  class InvalidMessageType < StandardError ; end

  MESSAGE_TEMPLATES = %w[
    forwarded_voicemail
    grocery_store_items_needed
  ].map(&:freeze).freeze

  requires :message_params, Hash
  requires :message_type, String, inclusion: MESSAGE_TEMPLATES
  requires :user, User

  returns :message_body, String, presence: true

  def execute
    result.message_body = message_body
  end

  private

  def message_body
    case message_type
    when 'forwarded_voicemail' then forwarded_voicemail_message_body
    when 'grocery_store_items_needed' then grocery_store_items_needed_message_body
    end
  end

  def forwarded_voicemail_message_body
    ApplicationController.render(
      'sms_messages/forwarded_voicemail',
      layout: nil,
      locals: message_params,
    ).rstrip
  end

  def grocery_store_items_needed_message_body
    store = user.stores.find(message_params['store_id'])
    ApplicationController.render(
      'sms_messages/grocery_list',
      layout: nil,
      locals: { store: store },
    ).rstrip
  end
end
