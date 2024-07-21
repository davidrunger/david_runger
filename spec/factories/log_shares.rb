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

FactoryBot.define do
  factory :log_share do
    association :log
    email { Faker::Internet.email }
  end
end
