# == Schema Information
#
# Table name: text_log_entries
#
#  created_at :datetime         not null
#  data       :text             not null
#  id         :bigint           not null, primary key
#  log_id     :bigint           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_text_log_entries_on_log_id  (log_id)
#

class LogEntries::TextLogEntry < LogEntry
  self.table_name = 'text_log_entries'
end
