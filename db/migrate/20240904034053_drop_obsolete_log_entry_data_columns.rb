class DropObsoleteLogEntryDataColumns < ActiveRecord::Migration[7.2]
  def change
    remove_column(:number_log_entry_data, :log_id, :bigint)
    remove_column(:number_log_entry_data, :note, :string)

    remove_column(:text_log_entry_data, :log_id, :bigint)
    remove_column(:text_log_entry_data, :note, :string)
  end
end
