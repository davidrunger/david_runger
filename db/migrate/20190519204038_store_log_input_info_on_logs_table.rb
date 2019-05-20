class StoreLogInputInfoOnLogsTable < ActiveRecord::Migration[5.2]
  def change
    change_table :logs, bulk: true do |t|
      t.text :data_label
      t.text :data_type
    end

    ApplicationRecord.connection.schema_cache.clear!
    Log.reset_column_information
  end
end
