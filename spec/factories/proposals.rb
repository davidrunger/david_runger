# == Schema Information
#
# Table name: proposals
#
#  accepted_at    :datetime
#  canceled_at    :datetime
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
#  uniq_pending_proposals          (proposer_id,proposee_email) UNIQUE WHERE ((accepted_at IS NULL) AND (canceled_at IS NULL))
#
FactoryBot.define do
  factory :proposal do
    association :proposer, factory: :user
    proposee_email { Faker::Internet.email }
  end
end
