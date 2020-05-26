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
# Indexes
#
#  index_ip_blocks_on_ip  (ip) UNIQUE
#
class IpBlock < ApplicationRecord
  validates :ip,
    presence: true,
    length: { maximum: 15 },
    format: { with: /\A([0-9]{1,3}\.?){4}\z/ },
    uniqueness: true
end
