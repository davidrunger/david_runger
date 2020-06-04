# frozen_string_literal: true

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
    phone { "1630#{rand(10_000_000).to_s.rjust(7, '5')}" }
    sms_allowance { 1.0 }

    trait :admin do
      email { 'davidjrunger@gmail.com' }
      sms_allowance { 10.0 }
    end
  end
end
