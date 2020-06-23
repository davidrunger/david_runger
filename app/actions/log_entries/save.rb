# frozen_string_literal: true

class LogEntries::Save < ApplicationAction
  requires :log_entry, ->(log_entry) { log_entry.is_a?(LogEntry) && log_entry.valid? }

  def execute
    log_entry.save!
    LogEntriesChannel.broadcast_to(
      log_entry.log,
      LogEntrySerializer.new(log_entry).as_json,
    )
  end
end
