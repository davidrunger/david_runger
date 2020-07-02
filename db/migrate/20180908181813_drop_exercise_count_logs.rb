# frozen_string_literal: true

class DropExerciseCountLogs < ActiveRecord::Migration[5.2]
  def change
    drop_table(:exercise_count_logs)
  end
end
