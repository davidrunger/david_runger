# == Schema Information
#
# Table name: proposals
#
#  accepted_at    :datetime
#  created_at     :datetime         not null
#  id             :bigint           not null, primary key
#  proposee_email :string           not null
#  proposer_id    :bigint           not null
#  public_id      :string           not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_proposals_on_proposer_id  (proposer_id)
#  index_proposals_on_public_id    (public_id) UNIQUE
#  uniq_pending_proposals          (proposer_id,proposee_email) UNIQUE WHERE (accepted_at IS NULL)
#
class Proposal < ApplicationRecord
  belongs_to :proposer, class_name: 'User', inverse_of: :sent_proposals

  has_secure_token :public_id

  normalizes :proposee_email, with: ->(email) { email.downcase }

  validates :proposee_email, presence: true, email_format: true
  validates(
    :proposee_email,
    uniqueness: {
      scope: :proposer_id,
      conditions: -> { where(accepted_at: nil) },
    },
    if: -> { accepted_at.nil? },
  )
  validates :public_id, presence: true, uniqueness: true

  scope :pending, -> { where(accepted_at: nil) }

  def to_param
    public_id
  end
end
