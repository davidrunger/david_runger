# frozen_string_literal: true

class DropUsersAuthTokenColumn < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :auth_token, :string
  end
end
