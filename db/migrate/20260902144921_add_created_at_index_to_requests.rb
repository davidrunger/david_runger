class AddCreatedAtIndexToRequests < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    add_index(:requests, :created_at, algorithm: :concurrently)
  end

  def down
    remove_index(:requests, :created_at, algorithm: :concurrently)
  end
end
