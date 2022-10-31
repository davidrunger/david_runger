# frozen_string_literal: true

class CreateLogEntry
  prepend ApplicationWorker

  def perform(log_entry_klass, log_entry_attributes_json)
    klass = log_entry_klass.constantize
    klass.create!(JSON(log_entry_attributes_json))
  end
end
