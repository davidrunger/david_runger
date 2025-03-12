class LogToCsv
  def initialize(log)
    @log = log
  end

  def csv_data
    CSV.generate(headers: true) do |csv|
      csv << ['Time', @log.data_label]

      @log.
        log_entries.
        includes(:log_entry_datum).
        find_each(
          order: :desc,
          cursor: %i[created_at id],
        ) do |log_entry|
          csv << [log_entry.created_at.utc.iso8601, log_entry.data]
        end
    end
  end
end
