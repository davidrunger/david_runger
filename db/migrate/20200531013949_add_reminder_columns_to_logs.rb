# frozen_string_literal: true

class AddReminderColumnsToLogs < ActiveRecord::Migration[6.1]
  def change
    # rubocop:disable Rails/BulkChangeTable
    add_column :logs, :reminder_time_in_seconds, :integer, comment: <<~COMMENT.squish
      Time in seconds, which, if elapsed since the creation of log or most recent log entry
      (whichever is later) will trigger a reminder to be sent (via email) to the owning user.
    COMMENT
    add_column :logs, :reminder_last_sent_at, :datetime
    # rubocop:enable Rails/BulkChangeTable
  end
end
