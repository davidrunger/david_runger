# frozen_string_literal: true

class AddPreferncesColumnToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :preferences, :jsonb, null: false, default: {}
  end
end
