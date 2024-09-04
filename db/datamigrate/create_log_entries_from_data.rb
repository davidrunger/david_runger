class CreateLogEntriesFromData
  def run
    NumberLogEntryDatum.find_each do |number_log_entry_datum|
      LogEntry.create!(
        log_id: number_log_entry_datum.log_id,
        note: number_log_entry_datum.note,
        # NOTE: created_at will be the "original" created at time that we want to preserve,
        # but updated_at will reflect the true time of this datamigration.
        created_at: number_log_entry_datum.created_at,
        log_entry_datum: number_log_entry_datum,
      )
    end

    TextLogEntryDatum.find_each do |text_log_entry_datum|
      LogEntry.create!(
        log_id: text_log_entry_datum.log_id,
        note: text_log_entry_datum.note,
        # NOTE: created_at will be the "original" created at time that we want to preserve,
        # but updated_at will reflect the true time of this datamigration.
        created_at: text_log_entry_datum.created_at,
        log_entry_datum: text_log_entry_datum,
      )
    end
  end
end

CreateLogEntriesFromData.new.run
