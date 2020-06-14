# frozen_string_literal: true

class SmsRecords::GenerateMessage < ApplicationAction
  class InvalidMessageType < StandardError ; end

  requires :message_params, Hash
  requires :message_type, String
  requires :user, User

  returns :message_body, String

  def execute
    result.message_body = message_body
  end

  private

  def message_body
    case message_type
    when 'grocery_store_items_needed' then grocery_store_items_needed_message_body
    else fail InvalidMessageType, "`#{message_type}` is not a valid message type"
    end
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
