class ScopeCiStepResultUniquenessToUser < ActiveRecord::Migration[8.1]
  def up
    add_index :ci_step_results,
              %i[user_id name github_run_id github_run_attempt],
              unique: true
    remove_index :ci_step_results, %i[name github_run_id github_run_attempt]
    remove_index :ci_step_results, :user_id
  end

  def down
    add_index :ci_step_results,
              %i[name github_run_id github_run_attempt],
              unique: true
    add_index :ci_step_results, :user_id, if_not_exists: true
    remove_index :ci_step_results, %i[user_id name github_run_id github_run_attempt]
  end
end
