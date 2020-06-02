# frozen_string_literal: true

# == Schema Information
#
# Table name: stores
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string           not null
#  notes      :text
#  updated_at :datetime         not null
#  user_id    :bigint
#  viewed_at  :datetime
#
# Indexes
#
#  index_stores_on_user_id  (user_id)
#

class Store < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy
  validates :name, presence: true
end
