class AddStandardTimestampsToRequests < ActiveRecord::Migration[8.1]
  def change
    add_timestamps(:requests, null: true)
  end
end
