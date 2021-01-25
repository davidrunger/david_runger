# frozen_string_literal: true

class LogEntryCopier
  extend Memoist

  def copy_log_entries
    copy_entries_for_table('number_log_entries')
    copy_entries_for_table('text_log_entries')
  end

  private

  def copy_entries_for_table(table_name)
    attributes_hashes = connection.execute("SELECT * FROM #{table_name}").to_a
    attributes_hashes.each_with_index do |attributes, index|
      puts("Copying #{index + 1} of #{attributes_hashes.size} from #{table_name}")
      log = log(attributes['log_id'])
      LogEntries::Create.new(log: log, attributes: attributes.except('id')).run!
    end
  end

  def connection
    ApplicationRecord.connection
  end

  memoize \
  def log(log_id)
    Log.find(log_id)
  end
end
