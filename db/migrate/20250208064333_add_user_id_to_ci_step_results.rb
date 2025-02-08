class AddUserIdToCiStepResults < ActiveRecord::Migration[8.0]
  def change
    add_reference :ci_step_results, :user, null: false, foreign_key: true
  end
end
