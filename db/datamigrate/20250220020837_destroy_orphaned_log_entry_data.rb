class DestroyOrphanedLogEntryData < Datamigration
  def run
    logging_start_and_finish do
      within_transaction do
        destroy_orphaned_number_log_entry_data
        destroy_orphaned_text_log_entry_data
      end
    end
  end

  private

  def destroy_orphaned_number_log_entry_data
    # We expect 0.
    if orphaned_number_log_entry_data.count <= 5
      log(<<~LOG.squish)
        About to destroy #{orphaned_number_log_entry_data.count} orphaned number log entry data.
      LOG

      orphaned_number_log_entry_data.find_each(&:destroy!)

      log('Done destroying orphaned number log entry data.')
    else
      fail 'There were unexpectedly many orphaned number log entry data.'
    end
  end

  def destroy_orphaned_text_log_entry_data
    # We expect 16.
    if orphaned_text_log_entry_data.count <= 20
      log(<<~LOG.squish)
        About to destroy #{orphaned_text_log_entry_data.count} orphaned text log entry data.
      LOG

      orphaned_text_log_entry_data.find_each(&:destroy!)

      log('Done destroying orphaned text log entry data.')
    else
      fail 'There were unexpectedly many orphaned text log entry data.'
    end
  end

  def orphaned_number_log_entry_data
    NumberLogEntryDatum.left_outer_joins(:log_entry).where(log_entries: { id: nil })
  end

  def orphaned_text_log_entry_data
    TextLogEntryDatum.left_outer_joins(:log_entry).where(log_entries: { id: nil })
  end
end

DestroyOrphanedLogEntryData.new.run
