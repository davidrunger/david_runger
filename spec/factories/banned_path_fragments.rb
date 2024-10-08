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
FactoryBot.define do
  factory :banned_path_fragment do
    value { "/#{Faker::Internet.unique.slug}.php" }
  end
end
