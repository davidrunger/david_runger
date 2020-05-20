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
class IpBlock < ApplicationRecord
  validates :ip, presence: true, length: {maximum: 15}, format: {with: /\A([0-9]{1,3}\.?){4}\z/}
end
