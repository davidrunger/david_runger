class IndexRequestsOnHandlerAndIp < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :requests, :handler, algorithm: :concurrently
    add_index :requests, :ip, algorithm: :concurrently
  end
end
