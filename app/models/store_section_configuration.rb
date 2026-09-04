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
#  index_store_section_configurations_on_user_id_and_store_id     (user_id,store_id) UNIQUE
#
class StoreSectionConfiguration < ApplicationRecord
  belongs_to :user
  belongs_to :store
  belongs_to :store_section_scheme, optional: true
  has_many :item_section_assignments, dependent: :destroy

  validates :store_id, uniqueness: { scope: :user_id }
  validates :store_section_scheme, presence: true, if: :sectioning_enabled?
  validate :store_is_available_to_user
  validate :scheme_belongs_to_user

  has_paper_trail

  private

  def store_is_available_to_user
    if !user || !store || !store.user_id.in?([user_id, user.spouse&.id])
      errors.add(:store, 'must belong to the user or their spouse')
    end
  end

  def scheme_belongs_to_user
    if (
      store_section_scheme_id.present? &&
        (!store_section_scheme || store_section_scheme.user_id != user_id)
    )
      errors.add(:store_section_scheme, 'must belong to the user')
    end
  end
end
