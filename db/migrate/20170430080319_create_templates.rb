# frozen_string_literal: true

class CreateTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :templates do |t|
      t.string :name
      t.string :body
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
