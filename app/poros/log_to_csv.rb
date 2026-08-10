class LogToCsv
  def initialize(log, neutralize_formulas: true)
    @log = log
    @neutralize_formulas = neutralize_formulas
  end

  def csv_data
    CSV.generate(headers: true) do |csv|
      csv << ['Time', exported_cell_value(@log.data_label)]

      @log.
        log_entries.
        includes(:log_entry_datum).
        find_each(
          order: :desc,
          cursor: %i[created_at id],
        ) do |log_entry|
          csv << [
            log_entry.created_at.utc.iso8601,
            exported_cell_value(log_entry.data),
          ]
        end
    end
  end

  private

  def exported_cell_value(value)
    if @neutralize_formulas && value.is_a?(String) && value.match?(/\A[=+\-@]/)
      "'#{value}"
    else
      value
    end
  end
end
