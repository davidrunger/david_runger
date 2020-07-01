# frozen_string_literal: true

class CreateExerciseCountLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :exercise_count_logs do |t|
      t.references :exercise, foreign_key: true, null: false
      t.integer :count, null: false
      t.string :note

      t.timestamps
    end
    add_index :exercise_count_logs, :created_at
  end
end
