# frozen_string_literal: true

class CreateCheckIns < ActiveRecord::Migration[7.0]
  def change
    create_table :check_ins do |t|
      t.references :marriage, null: false, foreign_key: true

      t.timestamps
    end
  end
end
