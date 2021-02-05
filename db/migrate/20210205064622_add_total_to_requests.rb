# frozen_string_literal: true

class AddTotalToRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :requests, :total, :integer
  end
end
