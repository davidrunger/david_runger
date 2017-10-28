# == Schema Information
#
# Table name: users
#
#  created_at       :datetime         not null
#  email            :string           not null
#  id               :integer          not null, primary key
#  last_activity_at :datetime
#  phone            :string
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    last_activity_at { 2.months.ago }
  end
end
