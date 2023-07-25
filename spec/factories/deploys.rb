# frozen_string_literal: true

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

FactoryBot.define do
  factory :deploy do
    git_sha { SecureRandom.hex(20) }
  end
end
