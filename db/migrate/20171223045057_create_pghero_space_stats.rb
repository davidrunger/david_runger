class CreatePgheroSpaceStats < ActiveRecord::Migration[5.1]
  def change
    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table :pghero_space_stats do |t|
      # rubocop:enable Rails/CreateTableWithTimestamps
      t.text :database
      t.text :schema
      t.text :relation
      t.integer :size, limit: 8
      t.timestamp :captured_at
    end

    add_index :pghero_space_stats, %i[database captured_at]
  end
end
