class AddEmailSubmissionTokenLastRotatedAtToLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :logs, :email_submission_token_last_rotated_at, :datetime
  end
end
