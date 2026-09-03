# == Schema Information
#
# Table name: item_availabilities
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  item_id    :bigint           not null
#  store_id   :bigint           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_item_availabilities_on_item_id_and_store_id  (item_id,store_id) UNIQUE
#  index_item_availabilities_on_store_id              (store_id)
#
class ItemAvailability < ApplicationRecord
  belongs_to :item, inverse_of: :item_availabilities
  belongs_to :store, inverse_of: :item_availabilities
  has_many :item_section_assignments, dependent: :delete_all

  validates :store_id, uniqueness: { scope: :item_id }
  validate :store_belongs_to_item_user

  has_paper_trail

  private

  def store_belongs_to_item_user
    if item && store && item.user_id != store.user_id
      errors.add(:store, "must belong to the item's user")
    end
  end
end
