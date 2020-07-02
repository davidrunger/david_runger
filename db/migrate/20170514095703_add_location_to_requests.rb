# frozen_string_literal: true

class AddLocationToRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :location, :string
  end
end
