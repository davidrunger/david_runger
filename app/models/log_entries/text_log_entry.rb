# frozen_string_literal: true

# == Schema Information
#
# Table name: text_log_entries
#
#  created_at :datetime         not null
#  data       :text             not null
#  id         :bigint           not null, primary key
#  log_id     :bigint           not null
#  note       :string
#  updated_at :datetime         not null
#

class LogEntries::TextLogEntry < LogEntry
  self.table_name = 'text_log_entries'
end
