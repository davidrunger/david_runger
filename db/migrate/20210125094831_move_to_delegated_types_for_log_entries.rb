# frozen_string_literal: true

require Rails.root.join('db/datamigrate/copy_log_entries_to_new_tables.rb')

class MoveToDelegatedTypesForLogEntries < ActiveRecord::Migration[6.1]
  def up
    # 1. Create new tables
    create_table :log_entries do |t|
      t.references :log, null: false, foreign_key: true
      t.text :note
      t.bigint :data_logable_id, null: false
      t.string :data_logable_type, null: false
      t.timestamps
      t.index %i[data_logable_id data_logable_type], unique: true
    end

    create_table :textual_data do |t|
      t.text :value, null: false
      t.timestamps
    end

    create_table :numeric_data do |t|
      t.float :value, null: false
      t.timestamps
    end

    # 2. Copy log entries
    LogEntryCopier.new.copy_log_entries

    # 3. Drop old tables
    drop_table :number_log_entries
    drop_table :text_log_entries
  end

  def down
    drop_table :log_entries
    drop_table :textual_data
    drop_table :numeric_data

    create_table :number_log_entries do |t|
      t.references :log, null: false, foreign_key: true
      t.float :data, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :note
    end

    create_table :text_log_entries do |t|
      t.references :log, null: false, foreign_key: true
      t.text :data, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :note
    end
  end
end
