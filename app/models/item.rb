class Item < ApplicationRecord
  belongs_to :store

  scope :not_archived, -> { where.not(archived: true) }
end
