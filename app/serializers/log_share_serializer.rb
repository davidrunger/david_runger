# == Schema Information
#
# Table name: log_shares
#
#  created_at :datetime         not null
#  email      :text             not null
#  id         :bigint           not null, primary key
#  log_id     :bigint           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_log_shares_on_log_id_and_email  (log_id,email) UNIQUE
#
class LogShareSerializer < ApplicationSerializer
  attributes :email, :id
end
