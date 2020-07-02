# frozen_string_literal: true

class RemoveColumnsFromUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :remember_created_at, :datetime
    remove_column :users, :sign_in_count, :integer
    remove_column :users, :last_sign_in_at, :datetime
    remove_column :users, :current_sign_in_ip, :inet
    remove_column :users, :last_sign_in_ip, :inet
    remove_column :users, :provider, :string
    remove_column :users, :uid, :string
  end
end
