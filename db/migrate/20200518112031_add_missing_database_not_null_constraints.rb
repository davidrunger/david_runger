# frozen_string_literal: true

class AddMissingDatabaseNotNullConstraints < ActiveRecord::Migration[6.1]
  def change
    change_column_null :requests, :status, false
    change_column_null :requests, :request_id, false
  end
end
