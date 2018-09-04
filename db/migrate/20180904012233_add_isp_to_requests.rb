class AddIspToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column(:requests, :isp, :string)
  end
end
