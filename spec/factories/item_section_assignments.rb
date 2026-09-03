# == Schema Information
#
# Table name: item_section_assignments
#
#  created_at                     :datetime         not null
#  id                             :bigint           not null, primary key
#  item_availability_id           :bigint           not null
#  store_section_configuration_id :bigint           not null
#  store_section_id               :bigint           not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  idx_on_store_section_configuration_id_09ee41d3e4                (store_section_configuration_id)
#  idx_on_store_section_configuration_id_item_availabi_90aa52d8d8  (store_section_configuration_id,item_availability_id) UNIQUE
#  index_item_section_assignments_on_item_availability_id          (item_availability_id)
#  index_item_section_assignments_on_store_section_id              (store_section_id)
#
FactoryBot.define do
  factory :item_section_assignment do
    association :store_section_configuration
    item_availability do
      association(:item_availability, store: store_section_configuration.store)
    end
    store_section do
      association(
        :store_section,
        store_section_scheme: store_section_configuration.store_section_scheme,
      )
    end
  end
end
