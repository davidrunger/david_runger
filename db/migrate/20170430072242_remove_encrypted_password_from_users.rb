# frozen_string_literal: true

class RemoveEncryptedPasswordFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :encrypted_password, :string
  end
end
