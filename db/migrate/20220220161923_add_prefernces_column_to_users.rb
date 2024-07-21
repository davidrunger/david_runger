class AddPreferncesColumnToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :preferences, :jsonb, null: false, default: {}
  end
end
