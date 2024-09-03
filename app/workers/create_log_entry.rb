class CreateLogEntry
  prepend ApplicationWorker

  def perform(log_entry_attributes_json)
    log_entry_attributes = JSON(log_entry_attributes_json)
    log_id = log_entry_attributes['log_id']
    log_entry = Log.find(log_id).build_log_entry_with_datum(log_entry_attributes)
    log_entry.save!
  end
end
