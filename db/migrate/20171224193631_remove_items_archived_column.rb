# frozen_string_literal: true

class RemoveItemsArchivedColumn < ActiveRecord::Migration[5.1]
  def change
    remove_column :items, :archived, :boolean, default: false, null: false
  end
end
