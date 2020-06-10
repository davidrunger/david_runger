# frozen_string_literal: true

require Rails.root.join('db/datamigrate/set_auth_token_for_users.rb')

class AddAuthTokenToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :auth_token, :text
    set_auth_token_for_users
    change_column_null :users, :auth_token, false
  end
end
