class CreateDatamigrationRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :datamigration_runs do |t|
      t.string :name, null: false
      t.string :developer, null: false
      t.datetime :completed_at

      t.timestamps
    end

    add_index :datamigration_runs, :developer
    add_index :datamigration_runs, :name
  end
end
