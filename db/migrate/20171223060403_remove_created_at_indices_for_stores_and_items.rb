# frozen_string_literal: true

class RemoveCreatedAtIndicesForStoresAndItems < ActiveRecord::Migration[5.1]
  def change
    remove_index :items, :created_at
    remove_index :stores, :created_at
  end
end
