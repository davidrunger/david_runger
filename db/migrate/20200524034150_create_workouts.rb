# frozen_string_literal: true

class CreateWorkouts < ActiveRecord::Migration[6.1]
  def change
    create_table :workouts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :time_in_seconds, null: false
      t.jsonb :rep_totals, null: false

      t.timestamps
    end
  end
end
