class DropLogInputsTable < ActiveRecord::Migration[5.2]
  def change
    # rubocop:disable Rails/ReversibleMigration
    drop_table :log_inputs
    # rubocop:enable Rails/ReversibleMigration
  end
end
