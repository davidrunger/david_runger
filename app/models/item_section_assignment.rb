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
#  idx_on_store_section_configuration_id_item_availabi_90aa52d8d8  (store_section_configuration_id,item_availability_id) UNIQUE
#  index_item_section_assignments_on_item_availability_id          (item_availability_id)
#  index_item_section_assignments_on_store_section_id              (store_section_id)
#
class ItemSectionAssignment < ApplicationRecord
  belongs_to :store_section_configuration
  belongs_to :item_availability
  belongs_to :store_section

  validates :item_availability_id, uniqueness: { scope: :store_section_configuration_id }
  validate :availability_belongs_to_configured_store
  validate :section_belongs_to_configured_scheme

  has_paper_trail

  private

  def availability_belongs_to_configured_store
    if (
      item_availability.present? && store_section_configuration.present? &&
        item_availability.store_id != store_section_configuration.store_id
    )
      errors.add(:item_availability, 'must belong to the configured store')
    end
  end

  def section_belongs_to_configured_scheme
    if (
      store_section.present? && store_section_configuration.present? &&
        store_section.store_section_scheme_id != store_section_configuration.store_section_scheme_id
    )
      errors.add(:store_section, 'must belong to the configured scheme')
    end
  end
end
