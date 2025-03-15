class CreatePgheroQueryStats < ActiveRecord::Migration[8.0]
  def change
    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table :pghero_query_stats do |t|
      t.text :database
      t.text :user
      t.text :query
      t.integer :query_hash, limit: 8
      t.float :total_time
      t.integer :calls, limit: 8
      t.timestamp :captured_at
    end
    # rubocop:enable Rails/CreateTableWithTimestamps

    add_index :pghero_query_stats, %i[database captured_at]
  end
end
