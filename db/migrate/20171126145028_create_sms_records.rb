# frozen_string_literal: true

class CreateSmsRecords < ActiveRecord::Migration[5.1]
  def change
    create_table(:sms_records, comment: 'Records of SMS messages sent via Nexmo') do |t|
      t.string(:nexmo_id, null: false, comment: 'The message id provided by Nexmo')
      t.string(:status, null: false, comment: 'The status code provided by Nexmo')
      t.string(:error, comment: 'Error description, provided by Nexmo, if present')
      t.string(:to, null: false, comment: 'The phone number to which the message was sent')
      t.float(:cost, comment: 'Cost of the message in EUR; may be NULL if send failed')
      t.references(:user, index: true, foreign_key: true)
    end
  end
end
