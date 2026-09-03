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
class StoreSection < ApplicationRecord
  belongs_to :store_section_scheme
  has_many :item_section_assignments, dependent: :destroy

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false, scope: :store_section_scheme_id }

  strip_attributes collapse_spaces: true

  has_paper_trail
end
