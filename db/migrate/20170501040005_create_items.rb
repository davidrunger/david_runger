# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.references :store, foreign_key: true, null: false, index: true
      t.string :name, null: false
      t.integer :needed, null: false, default: 1

      t.timestamps
    end
  end
end
