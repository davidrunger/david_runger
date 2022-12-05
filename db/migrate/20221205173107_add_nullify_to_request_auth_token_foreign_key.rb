# frozen_string_literal: true

class AddNullifyToRequestAuthTokenForeignKey < ActiveRecord::Migration[7.0]
  def change
    revert { add_foreign_key :requests, :auth_tokens }
    add_foreign_key :requests, :auth_tokens, on_delete: :nullify
  end
end
