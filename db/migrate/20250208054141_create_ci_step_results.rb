class CreateCiStepResults < ActiveRecord::Migration[8.0]
  def change
    create_table :ci_step_results do |t|
      t.string :name, null: false
      t.float :seconds, null: false
      t.datetime :started_at, null: false
      t.datetime :stopped_at, null: false
      t.boolean :passed, default: false, null: false
      t.bigint :github_run_id, null: false
      t.integer :github_run_attempt, null: false
      t.string :branch, null: false
      t.string :sha, null: false

      t.timestamps
    end
  end
end
