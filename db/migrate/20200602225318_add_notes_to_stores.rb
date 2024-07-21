class AddNotesToStores < ActiveRecord::Migration[6.1]
  def change
    add_column :stores, :notes, :text
  end
end
