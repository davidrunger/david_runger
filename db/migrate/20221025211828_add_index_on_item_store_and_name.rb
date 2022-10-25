# frozen_string_literal: true

class AddIndexOnItemStoreAndName < ActiveRecord::Migration[7.0]
  def change
    remove_index :items, :store_id
    add_index :items, %i[store_id name], unique: true
  end
end
