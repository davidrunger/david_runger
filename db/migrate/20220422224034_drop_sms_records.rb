# frozen_string_literal: true

class DropSmsRecords < ActiveRecord::Migration[6.1]
  def change
    drop_table(:sms_records) do |t|
      t.string 'nexmo_id', null: false, comment: 'The message id provided by Nexmo'
      t.string 'status', null: false, comment: 'The status code provided by Nexmo'
      t.string 'error', comment: 'Error description, provided by Nexmo, if present'
      t.string 'to', null: false, comment: 'The phone number to which the message was sent'
      t.float 'cost', comment: 'Cost of the message in EUR; may be NULL if send failed'
      t.bigint 'user_id', null: false
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.index ['nexmo_id'], name: 'index_sms_records_on_nexmo_id', unique: true
      t.index ['user_id'], name: 'index_sms_records_on_user_id'
    end
  end
end
