# frozen_string_literal: true

require Rails.root.join('db/datamigrate/copy_log_entries_to_type_specific_tables.rb')

class CreateSeparateLogEntryTablesPerType < ActiveRecord::Migration[5.2]
  def change
    create_table :text_log_entries do |t|
      t.references :log, null: false, foreign_key: true
      t.text :data, null: false

      t.timestamps
    end

    create_table :number_log_entries do |t|
      t.references :log, null: false, foreign_key: true
      t.float :data, null: false

      t.timestamps
    end

    copy_log_entries_to_type_specific_tables!

    # rubocop:disable Rails/ReversibleMigration
    drop_table :log_entries
    # rubocop:enable Rails/ReversibleMigration
  end
end
