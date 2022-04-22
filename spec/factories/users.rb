# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  created_at  :datetime         not null
#  email       :string           not null
#  id          :bigint           not null, primary key
#  preferences :jsonb            not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }

    trait :admin do
      email { 'davidjrunger@gmail.com' }
    end
  end
end
