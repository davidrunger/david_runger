class Item < ApplicationRecord
  belongs_to :store

  validates :name, presence: true

  scope :not_archived, -> { where.not(archived: true) }
end
