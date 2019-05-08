# == Schema Information
#
# Table name: log_inputs
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  index      :integer          default(0), not null
#  label      :string           not null
#  log_id     :bigint           not null
#  type       :string           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_log_inputs_on_log_id_and_index  (log_id,index) UNIQUE
#

class LogInputs::DurationLogInput < LogInput
end
