# frozen_string_literal: true

# == Schema Information
#
# Table name: sms_records
#
#  cost       :float
#  created_at :datetime         not null
#  error      :string
#  id         :bigint           not null, primary key
#  nexmo_id   :string           not null
#  status     :string           not null
#  to         :string           not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_sms_records_on_nexmo_id  (nexmo_id) UNIQUE
#

FactoryBot.define do
  factory :sms_record do
    error { nil }
    sequence(:nexmo_id) { |n| n.to_s.rjust(8, '0') }
    cost { [0.005, 0.006, 0.007].sample }
    status { '0' }
    to { '16303906690' }
    association :user
  end
end
