# frozen_string_literal: true

class LogEntries::Create < ApplicationAction
  requires :log, Log
  requires :attributes, Shaped::Shape(Hash, ActionController::Parameters)

  returns :log_entry, LogEntry

  def execute
    log_entry = log.build_log_entry(attributes)
    log_entry.save!
    result.log_entry = log_entry
    LogEntriesChannel.broadcast_to(log, LogEntrySerializer.new(result.log_entry).as_json)
  end
end
