# frozen_string_literal: true

def copy_log_entries_to_type_specific_tables!
  # iterate by log so that we know the type of log input
  Log.find_each do |log|
    log_input = log.log_inputs.first!
    new_log_entry_class =
      case log_input.type
      # (durations are recorded as strings, like "42:10")
      when 'LogInputs::DurationLogInput'
        LogEntries::TextLogEntry
      when 'LogInputs::IntegerLogInput'
        LogEntries::NumberLogEntry
      when 'LogInputs::TextLogInput'
        LogEntries::TextLogEntry
      end
    data_key = log_input.label

    log.log_entries.find_each do |log_entry|
      old_data = log_entry.data[data_key]
      data =
        if new_log_entry_class == LogEntries::NumberLogEntry
          Float(old_data.to_s.gsub(/[^\d.]/, ''))
        else
          old_data
        end

      new_log_entry_class.create!(
        created_at: log_entry.created_at, # updated_at will reflect the actual time of creation
        data: data,
        log: log,
      )
    end
  end
end
