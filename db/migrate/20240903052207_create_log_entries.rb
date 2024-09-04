class CreateLogEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :log_entries do |t|
      t.references :log, null: false, foreign_key: true
      t.string :log_entry_datum_type, null: false
      t.bigint :log_entry_datum_id, null: false
      t.string :note

      t.timestamps
    end

    add_index(:log_entries, %i[log_entry_datum_type log_entry_datum_id], unique: true)
  end
end
