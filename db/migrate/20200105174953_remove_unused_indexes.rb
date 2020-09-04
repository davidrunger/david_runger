# frozen_string_literal: true

class RemoveUnusedIndexes < ActiveRecord::Migration[6.0]
  def change
    # rubocop:disable Rails/ReversibleMigration
    remove_index :number_log_entries, name: 'index_number_log_entries_on_log_id'
    remove_index :text_log_entries, name: 'index_text_log_entries_on_log_id'
    remove_index :sms_records, name: 'index_sms_records_on_user_id'
    remove_index :stores, name: 'index_stores_on_user_id'
    # rubocop:enable Rails/ReversibleMigration
  end
end
