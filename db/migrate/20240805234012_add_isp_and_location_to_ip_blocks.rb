class AddIspAndLocationToIpBlocks < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :ip_blocks, :isp, :string
    add_column :ip_blocks, :location, :string

    add_index :ip_blocks, :isp, algorithm: :concurrently
  end
end
