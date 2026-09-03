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
#  index_store_section_schemes_on_user_id           (user_id)
#  index_store_section_schemes_on_user_id_and_name  (user_id, lower((name)::text)) UNIQUE
#
class StoreSectionSchemeSerializer < ApplicationSerializer
  attributes :id, :name
  many :store_sections, resource: StoreSectionSerializer
end
