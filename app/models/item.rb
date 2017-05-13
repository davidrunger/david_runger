# == Schema Information
#
# Table name: items
#
#  archived   :boolean          default("false"), not null
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string           not null
#  needed     :integer          default("1"), not null
#  store_id   :integer          not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_items_on_store_id  (store_id)
#

class Item < ApplicationRecord
  belongs_to :store

  validates :name, presence: true

  scope :not_archived, -> { where.not(archived: true) }
end
