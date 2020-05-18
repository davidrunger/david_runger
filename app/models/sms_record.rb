# frozen_string_literal: true

# == Schema Information
#
# Table name: sms_records
#
#  cost       :float
#  created_at :datetime         not null
#  error      :string
#  id         :bigint           not null, primary key
#  nexmo_id   :string           not null
#  status     :string           not null
#  to         :string           not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_sms_records_on_nexmo_id  (nexmo_id) UNIQUE
#  index_sms_records_on_user_id   (user_id)
#

class SmsRecord < ApplicationRecord
  validates :nexmo_id, presence: true
  validates :status, presence: true
  validates :to, presence: true

  belongs_to :user

  class << self
    def create_records_from_httparty_response(response:, user:)
      messages = response.parsed_response['messages']
      return false if messages.blank?

      messages.all? do |message_hash|
        user.sms_records.create(nexmo_message_hash_to_attributes(message_hash))
      end
    end

    private

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
end
