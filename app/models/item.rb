# == Schema Information
#
# Table name: items
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string           not null
#  needed     :integer          default(1), not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_items_on_user_id_and_lower_name  (user_id, lower((name)::text)) UNIQUE
#
class Item < ApplicationRecord
  include JsonBroadcastable

  belongs_to :user
  has_many :item_availabilities, dependent: :destroy, inverse_of: :item
  has_many :stores, through: :item_availabilities

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false, scope: :user_id }
  validates :needed, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :item_availabilities, presence: true

  strip_attributes collapse_spaces: true

  has_paper_trail

  scope :needed, -> { where('items.needed > 0') }
  scope :unneeded, -> { where(needed: 0) }
  scope :with_name, ->(name) { where('LOWER(items.name) = ?', name.downcase) }

  broadcasts_json_to(
    GroceriesChannel,
    ->(item) { item.user&.marriage },
  )
end
