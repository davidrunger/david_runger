# frozen_string_literal: true

class DeviseCreateAdminUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_users do |t|
      t.string :email, null: false
      t.timestamps null: false
    end

    add_index :admin_users, :email, unique: true
  end
end
