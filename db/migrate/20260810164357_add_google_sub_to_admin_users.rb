class AddGoogleSubToAdminUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_users, :google_sub, :string
  end
end
