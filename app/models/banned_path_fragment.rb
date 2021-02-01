# frozen_string_literal: true

# == Schema Information
#
# Table name: banned_path_fragments
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  notes      :text
#  updated_at :datetime         not null
#  value      :string           not null
#
class BannedPathFragment < ApplicationRecord
  validates :value, presence: true, format: { without: Rack::Attack::PATH_FRAGMENT_SEPARATOR_REGEX }
end
