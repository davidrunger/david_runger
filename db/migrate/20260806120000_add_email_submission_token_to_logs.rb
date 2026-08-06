class AddEmailSubmissionTokenToLogs < ActiveRecord::Migration[8.1]
  EMAIL_SUBMISSION_TOKEN_LENGTH = 24

  class MigrationLog < ActiveRecord::Base
    self.table_name = 'logs'
    self.record_timestamps = false
  end

  def up
    add_column :logs, :email_submission_token, :string
    add_index :logs, :email_submission_token, unique: true

    MigrationLog.reset_column_information
    MigrationLog.find_each do |log|
      log.update!(email_submission_token: SecureRandom.base58(EMAIL_SUBMISSION_TOKEN_LENGTH))
    end

    change_column_null :logs, :email_submission_token, false
  end

  def down
    remove_column :logs, :email_submission_token
  end
end
