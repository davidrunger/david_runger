class AddUniqueUserIdNameIndexForStores < ActiveRecord::Migration[7.1]
  def change
    remove_index :stores, :user_id
    add_index :stores, %i[user_id name], unique: true
  end
end
