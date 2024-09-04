# == Schema Information
#
# Table name: number_log_entry_data
#
#  created_at :datetime         not null
#  data       :float            not null
#  id         :bigint           not null, primary key
#  log_id     :bigint
#  note       :string
#  updated_at :datetime         not null
#
# Indexes
#
#  index_number_log_entry_data_on_log_id  (log_id)
#
class NumberLogEntryDatum < ApplicationRecord
  include LogEntryDatum
end
