# frozen_string_literal: true

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
    format: { with: /\A[a-z0-9]+\z/ },
    uniqueness: true,
  )
end
