# == Schema Information
#
# Table name: deploys
#
#  created_at :datetime         not null
#  git_sha    :string           not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#
# Indexes
#
#  index_deploys_on_git_sha  (git_sha)
#
class Deploy < ApplicationRecord
  validates :git_sha, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at git_sha id updated_at]
  end
end
