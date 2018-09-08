class DropExercises < ActiveRecord::Migration[5.2]
  def change
    # rubocop:disable Rails/ReversibleMigration
    drop_table(:exercises)
    # rubocop:enable Rails/ReversibleMigration
  end
end
