class AddPrivateToStores < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :private, :boolean, null: false, default: false
  end
end
