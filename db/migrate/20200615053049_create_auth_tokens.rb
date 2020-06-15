# frozen_string_literal: true

class CreateAuthTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :auth_tokens do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.text :secret, null: false
      t.text :name
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :auth_tokens, %i[user_id secret], unique: true
  end
end
