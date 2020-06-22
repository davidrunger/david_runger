# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string           not null
#  needed     :integer          default(1), not null
#  store_id   :bigint           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_items_on_store_id  (store_id)
#

class Item < ApplicationRecord
  belongs_to :store
  has_one :user, through: :store

  validates :name, presence: true

  scope :needed, -> { where('items.needed > 0') }
end
