class RemoveRequestedAtFromRequests < ActiveRecord::Migration[8.1]
  def up
    remove_column(:requests, :requested_at)
  end

  def down
    add_column(:requests, :requested_at, :datetime, precision: nil)
  end
end
