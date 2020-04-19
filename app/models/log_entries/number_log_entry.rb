# frozen_string_literal: true

# == Schema Information
#
# Table name: number_log_entries
#
#  created_at :datetime         not null
#  data       :float            not null
#  id         :bigint           not null, primary key
#  log_id     :bigint           not null
#  note       :string
#  updated_at :datetime         not null
#

class LogEntries::NumberLogEntry < LogEntry
  self.table_name = 'number_log_entries'
end
