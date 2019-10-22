# frozen_string_literal: true

class AddRequestIdToRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :request_id, :string
    add_index :requests, :request_id, unique: true
  end
end
