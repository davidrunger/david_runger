# frozen_string_literal: true

class SmsMessage
  class InvalidMessageTypeError < StandardError ; end
  class SaveSmsRecordError < StandardError ; end

  extend Memoist
  include ActiveModel::Model

  MESSAGE_TYPES = %w[
    grocery_store_items_needed
  ].map(&:freeze).freeze

  validates :message_type, inclusion: MESSAGE_TYPES
  validates :user_phone, presence: true

  delegate :phone, to: :user, prefix: true

  attr_reader :message_type, :user

  def initialize(user:, message_type:, message_params:)
    @user = user
    @message_type = message_type
    @message_params = message_params
  end

  def send!
    if ENV['NEXMO_API_KEY'].blank?
      message_body # memoize `message_body` so that ActiveRecord queries don't get logged below
      # print message to facilitate debugging (e.g. particularly in development)
      puts('NEXMO_API_KEY is blank; message would have been:')
      puts('~~~~~~~~~~~~~~~~~~~~~')
      puts(message_body)
      puts('=====================')
      return false
    end

    nexmo_response = NexmoClient.send_text!(number: @user.phone, message: message_body)
    if nexmo_response.success?
      save_sms_record(nexmo_response)
      true
    else
      false
    end
  end

  private

  memoize \
  def message_body
    case @message_type
    when 'grocery_store_items_needed' then grocery_store_items_needed_message_body
    else fail InvalidMessageTypeError, "`#{@message_type}` is not a valid message type"
    end
  end

  def save_sms_record(nexmo_response)
    if SmsRecord.create_records_from_httparty_response(response: nexmo_response, user: @user)
      true
    else
      Rails.logger.error(<<~LOG.squish)
        Failed to create SmsRecord(s),
        user=#{@user&.id}, message_type=#{@message_type}, message_params=#{@message_params}
      LOG
      Rollbar.error(
        SaveSmsRecordError.new,
        user: @user&.id,
        message_type: @message_type,
        message_params: @message_params,
      )
      false
    end
  end

  def grocery_store_items_needed_message_body
    store = @user.stores.find(@message_params['store_id'])
    ApplicationController.render(
      'sms_messages/grocery_list',
      layout: nil,
      locals: { store: store },
    ).rstrip
  end
end
