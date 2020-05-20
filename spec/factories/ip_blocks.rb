# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_blocks
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  ip         :text             not null
#  reason     :text
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :ip_block do
    ip { Faker::Internet.ip_v4_address }
    reason { 'tried to access wp-login.php too many times' }
  end
end
