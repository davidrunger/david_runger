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
# Indexes
#
#  index_banned_path_fragments_on_value  (value) UNIQUE
#

FactoryBot.define do
  factory :banned_path_fragment do
    value { "/#{Faker::Internet.unique.slug}.php" }
    notes { 'PHP route requested in scanning attack' }
  end
end
