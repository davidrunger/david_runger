class RemoveBotColumnFromRequests < ActiveRecord::Migration[5.2]
  def change
    remove_column(:requests, :bot, :boolean)
  end
end
