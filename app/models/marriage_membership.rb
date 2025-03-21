# == Schema Information
#
# Table name: marriage_memberships
#
#  created_at  :datetime         not null
#  id          :bigint           not null, primary key
#  marriage_id :bigint           not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_marriage_memberships_on_marriage_id  (marriage_id)
#  index_marriage_memberships_on_user_id      (user_id) UNIQUE
#
class MarriageMembership < ApplicationRecord
  belongs_to :marriage
  belongs_to :user

  validates :user_id, uniqueness: true
  validate :marriage_has_max_2_partners

  def marriage_has_max_2_partners
    if marriage.memberships.size > 2
      errors.add(:base, 'No more than two partners may join a marriage')
    end
  end
end
