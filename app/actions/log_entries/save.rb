# frozen_string_literal: true

class LogEntries::Save < ApplicationAction
  requires :log_entry, Shaped::Shapes::All.new(LogEntry, :valid?)

  def execute
    log_entry.save!
    LogEntriesChannel.broadcast_to(
      log_entry.log,
      LogEntrySerializer.new(log_entry).as_json,
    )
  end
end
