class LogEntries::Save < ApplicationAction
  requires :log_entry, Shaped::Shapes::All.new(LogEntry, :valid?)

  def execute
    log_entry.save!
  end
end
