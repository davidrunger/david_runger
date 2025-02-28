class AddPublicNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :public_name, :string
  end
end
