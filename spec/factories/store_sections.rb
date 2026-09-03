# == Schema Information
#
# Table name: store_sections
#
#  created_at              :datetime         not null
#  id                      :bigint           not null, primary key
#  name                    :string           not null
#  store_section_scheme_id :bigint           not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_store_sections_on_scheme_id_and_name       (store_section_scheme_id, lower((name)::text)) UNIQUE
#  index_store_sections_on_store_section_scheme_id  (store_section_scheme_id)
#
FactoryBot.define do
  factory :store_section do
    association :store_section_scheme
    sequence(:name) { |number| "Section #{number}" }
  end
end
