class MakeLogIdNullableForLogEntryDataTables < ActiveRecord::Migration[7.2]
  def change
    change_column_null :number_log_entry_data, :log_id, true
    change_column_null :text_log_entry_data, :log_id, true
  end
end
