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
#  index_items_on_store_id_and_name  (store_id,name) UNIQUE
#
class Item < ApplicationRecord
  include JsonBroadcastable

  belongs_to :store
  has_one :user, through: :store

  validates :name, presence: true, uniqueness: { scope: :store_id }

  strip_attributes collapse_spaces: true

  has_paper_trail

  scope :needed, -> { where('items.needed > 0') }
  scope :unneeded, -> { where(needed: 0) }

  broadcasts_json_to(
    GroceriesChannel,
    ->(item) { item.user&.marriage },
    unless_for_destroyed: ->(item) { item.store.destroyed? },
  )
end
