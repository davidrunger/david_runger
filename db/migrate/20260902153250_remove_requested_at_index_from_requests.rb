class RemoveRequestedAtIndexFromRequests < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    remove_index(:requests, :requested_at, algorithm: :concurrently)
  end

  def down
    add_index(:requests, :requested_at, algorithm: :concurrently)
  end
end
