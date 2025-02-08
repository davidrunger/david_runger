class AddUniqueIndexToCiStepResults < ActiveRecord::Migration[8.0]
  def change
    add_index :ci_step_results, %i[name github_run_id github_run_attempt], unique: true
  end
end
