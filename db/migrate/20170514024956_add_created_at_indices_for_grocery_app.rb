# frozen_string_literal: true

class AddCreatedAtIndicesForGroceryApp < ActiveRecord::Migration[5.1]
  def change
    add_index :items, :created_at
    add_index :stores, :created_at
  end
end
