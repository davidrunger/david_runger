class DropExerciseCountLogs < ActiveRecord::Migration[5.2]
  def change
    # rubocop:disable Rails/ReversibleMigration
    drop_table(:exercise_count_logs)
    # rubocop:enable Rails/ReversibleMigration
  end
end
