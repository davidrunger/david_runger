class AddForeignKeysToEvents < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key 'events', 'admin_users'
    add_foreign_key 'events', 'users'
  end
end
