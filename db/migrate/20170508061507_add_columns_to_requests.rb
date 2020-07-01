# frozen_string_literal: true

class AddColumnsToRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :format, :string, null: false
    add_column :requests, :status, :integer
    add_column :requests, :view, :integer
    add_column :requests, :db, :integer
  end
end
