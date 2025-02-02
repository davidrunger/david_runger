class RemoveIspIndexes < ActiveRecord::Migration[8.0]
  def change
    remove_index :ip_blocks, :isp
    remove_index :requests, :isp
  end
end
