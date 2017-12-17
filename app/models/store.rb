# == Schema Information
#
# Table name: stores
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#  user_id    :integer
#  viewed_at  :datetime
#
# Indexes
#
#  index_stores_on_created_at  (created_at)
#  index_stores_on_user_id     (user_id)
#

class Store < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy
  validates :name, presence: true
end
