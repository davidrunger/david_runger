# == Schema Information
#
# Table name: number_log_entry_data
#
#  created_at :datetime         not null
#  data       :float            not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#
class NumberLogEntryDatum < ApplicationRecord
  include LogEntryDatum
end
