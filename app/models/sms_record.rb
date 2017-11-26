# == Schema Information
#
# Table name: sms_records
#
#  cost     :float
#  error    :string
#  id       :integer          not null, primary key
#  nexmo_id :string           not null
#  status   :string           not null
#  to       :string           not null
#  user_id  :integer
#
# Indexes
#
#  index_sms_records_on_user_id  (user_id)
#

class SmsRecord < ApplicationRecord
  validates :nexmo_id, presence: true
  validates :status, presence: true
  validates :to, presence: true

  belongs_to :user
end
