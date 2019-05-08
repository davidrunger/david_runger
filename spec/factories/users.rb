# == Schema Information
#
# Table name: users
#
#  created_at       :datetime         not null
#  email            :string           not null
#  id               :bigint           not null, primary key
#  last_activity_at :datetime
#  phone            :string
#  sms_allowance    :float            default(1.0), not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    last_activity_at { 2.months.ago }
    phone { '16303906690' }
  end
end
