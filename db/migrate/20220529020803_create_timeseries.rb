# frozen_string_literal: true

class CreateTimeseries < ActiveRecord::Migration[6.1]
  def change
    create_table :timeseries do |t|
      t.text :name, null: false
      t.json :measurements, null: false, default: []

      t.timestamps
    end
  end
end
