# frozen_string_literal: true

class AddIndexForAuthTokensSecret < ActiveRecord::Migration[6.1]
  def change
    add_index :auth_tokens, :secret
  end
end
