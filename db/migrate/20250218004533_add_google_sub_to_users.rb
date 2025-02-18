class AddGoogleSubToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_sub, :string
  end
end
