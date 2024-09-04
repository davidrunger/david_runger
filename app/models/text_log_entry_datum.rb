# == Schema Information
#
# Table name: text_log_entry_data
#
#  created_at :datetime         not null
#  data       :text             not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#
class TextLogEntryDatum < ApplicationRecord
  include LogEntryDatum
end
