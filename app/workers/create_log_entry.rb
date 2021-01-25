# frozen_string_literal: true

class CreateLogEntry
  prepend ApplicationWorker

  def perform(log_entry_attributes)
    log = Log.find(log_entry_attributes['log_id'])
    LogEntries::Create.new(log: log, attributes: log_entry_attributes).run!
  end
end
