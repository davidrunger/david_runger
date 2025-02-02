# == Schema Information
#
# Table name: ip_blocks
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  ip         :string           not null
#  isp        :string
#  location   :string
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
    length: { maximum: 39 },
    format: { with: /\A[.:0-9a-f]{7,39}\z/ },
    uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id ip isp location reason updated_at]
  end
end
