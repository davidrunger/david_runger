# == Schema Information
#
# Table name: store_section_configurations
#
#  created_at              :datetime         not null
#  id                      :bigint           not null, primary key
#  sectioning_enabled      :boolean          default(FALSE), not null
#  store_id                :bigint           not null
#  store_section_scheme_id :bigint
#  updated_at              :datetime         not null
#  user_id                 :bigint           not null
#
# Indexes
#
#  index_store_section_configurations_on_store_id                 (store_id)
#  index_store_section_configurations_on_store_section_scheme_id  (store_section_scheme_id)
#  index_store_section_configurations_on_user_id                  (user_id)
#  index_store_section_configurations_on_user_id_and_store_id     (user_id,store_id) UNIQUE
#
FactoryBot.define do
  factory :store_section_configuration do
    association :user
    store { association(:store, user:) }
    sectioning_enabled { true }
    store_section_scheme { association(:store_section_scheme, user:) }

    trait :sectioning_disabled do
      sectioning_enabled { false }
      store_section_scheme { nil }
    end
  end
end
