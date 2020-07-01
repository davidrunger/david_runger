# frozen_string_literal: true

class AddArchivedToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :archived, :boolean, null: false, default: false
  end
end
