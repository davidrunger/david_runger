# frozen_string_literal: true

class AddMissingIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :sms_records, :user_id
    add_index :stores, :user_id
    add_index :number_log_entries, :log_id
    add_index :text_log_entries, :log_id
  end
end
