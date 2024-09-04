class RenameLogEntryDataTables < ActiveRecord::Migration[7.2]
  def change
    rename_table(:number_log_entries, :number_log_entry_data)
    rename_table(:text_log_entries, :text_log_entry_data)
  end
end
