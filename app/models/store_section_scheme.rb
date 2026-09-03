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
class StoreSectionScheme < ApplicationRecord
  belongs_to :user
  has_many :store_sections, dependent: :destroy
  has_many :store_section_configurations, dependent: :restrict_with_error

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false, scope: :user_id }

  strip_attributes collapse_spaces: true

  has_paper_trail
end
