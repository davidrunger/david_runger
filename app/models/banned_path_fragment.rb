# == Schema Information
#
# Table name: banned_path_fragments
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#  value      :string           not null
#
# Indexes
#
#  index_banned_path_fragments_on_value  (value) UNIQUE
#
class BannedPathFragment < ApplicationRecord
  validates(
    :value,
    presence: true,
    format: { with: /\A[a-z]+\z/ },
    uniqueness: true,
  )

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id updated_at value]
  end
end
