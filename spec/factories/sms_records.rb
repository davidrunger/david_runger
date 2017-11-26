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

FactoryGirl.define do
  factory :sms_record do
    error nil
    sequence(:nexmo_id) { |n| n.to_s.rjust(8, '0') }
    cost { [0.005, 0.006, 0.007].sample }
    status '0'
    to '16303906690'
    association :user
  end
end
