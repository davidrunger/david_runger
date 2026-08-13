class LogEntries::EnqueueFromCsv < ApplicationAction
  prepend Memoization

  JOB_ENQUEUE_BATCH_SIZE = 1_000
  MAX_LOG_ENTRIES = 10_000

  requires :csv_path, String
  requires :log, Log

  fails_with :invalid_upload

  def execute
    if csv_rows.size > MAX_LOG_ENTRIES
      result.invalid_upload!("Uploads may contain no more than #{MAX_LOG_ENTRIES} log entries.")
    else
      job_arguments = job_arguments_for(csv_rows)

      if job_arguments
        CreateLogEntry.perform_bulk(job_arguments, batch_size: JOB_ENQUEUE_BATCH_SIZE)
      else
        result.invalid_upload!(
          'The uploaded data is invalid. We have not entered it in the database.',
        )
      end
    end
  end

  private

  memoize \
  def csv_rows
    File.open(csv_path) do |csv_file|
      CSV.new(csv_file, headers: true).take(MAX_LOG_ENTRIES + 1)
    end
  end

  def job_arguments_for(csv_rows)
    all_log_entries_valid = true
    job_arguments = []

    csv_rows.each do |row|
      log_entry = build_log_entry(row)
      if !log_entry.valid?
        all_log_entries_valid = false
        break
      end

      job_arguments << [attributes_for_job(log_entry)]
    ensure
      # `build_log_entry_with_datum` adds each unsaved entry to the association target. Clear it so
      # that validating an upload does not retain thousands of Active Record objects in memory.
      log.log_entries.reset
    end

    job_arguments if all_log_entries_valid
  end

  def build_log_entry(row)
    attributes = row.to_h
    created_at_string = attributes['created_at']
    created_at = (Time.iso8601(created_at_string) rescue Date.iso8601(created_at_string))
    attributes['created_at'] = created_at
    attributes['updated_at'] = created_at
    log.build_log_entry_with_datum(attributes)
  end

  def attributes_for_job(log_entry)
    log_entry.
      attributes.
      merge(log_entry.log_entry_datum.attributes.slice('data')).
      compact.
      as_json
  end
end
