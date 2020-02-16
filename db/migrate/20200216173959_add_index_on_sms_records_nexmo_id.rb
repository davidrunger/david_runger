# frozen_string_literal: true

class AddIndexOnSmsRecordsNexmoId < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :sms_records, :nexmo_id, unique: true, algorithm: :concurrently
  end
end
