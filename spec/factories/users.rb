# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  created_at    :datetime         not null
#  email         :string           not null
#  id            :bigint           not null, primary key
#  phone         :string
#  sms_allowance :float            default(1.0), not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    phone { "1630#{Array.new(7) { rand(10).to_s }.join('')}" }
    sms_allowance { 1.0 }

    trait :admin do
      email { 'davidjrunger@gmail.com' }
      sms_allowance { 10.0 }
    end
  end
end
