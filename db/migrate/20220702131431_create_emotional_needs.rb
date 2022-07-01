# frozen_string_literal: true

class CreateEmotionalNeeds < ActiveRecord::Migration[7.0]
  def change
    create_table :emotional_needs do |t|
      t.references :marriage, null: false, foreign_key: true
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
