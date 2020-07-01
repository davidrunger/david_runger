# frozen_string_literal: true

class AddMethodToRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :method, :string, null: false
  end
end
