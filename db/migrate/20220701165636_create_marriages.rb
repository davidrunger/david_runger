# frozen_string_literal: true

class CreateMarriages < ActiveRecord::Migration[7.0]
  def change
    create_table :marriages do |t|
      t.references :partner_1, null: false, foreign_key: { to_table: 'users' }
      t.references :partner_2, null: true, foreign_key: { to_table: 'users' }

      t.timestamps
    end
  end
end
