# == Schema Information
#
# Table name: store_section_schemes
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_store_section_schemes_on_user_id_and_name  (user_id, lower((name)::text)) UNIQUE
#
FactoryBot.define do
  factory :store_section_scheme do
    association :user
    sequence(:name) { |number| "Store sections #{number}" }
  end
end
