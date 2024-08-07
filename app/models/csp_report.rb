# == Schema Information
#
# Table name: csp_reports
#
#  blocked_uri        :string
#  created_at         :datetime         not null
#  document_uri       :string           not null
#  id                 :bigint           not null, primary key
#  ip                 :string           not null
#  original_policy    :string           not null
#  referrer           :string
#  updated_at         :datetime         not null
#  user_agent         :text             not null
#  violated_directive :string           not null
#
class CspReport < ApplicationRecord
  validates :document_uri, presence: true
  validates :violated_directive, presence: true
  validates :original_policy, presence: true
  validates :ip, presence: true
  validates :user_agent, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      blocked_uri
      created_at
      document_uri
      id
      ip
      original_policy
      referrer
      updated_at
      user_agent
      violated_directive
    ]
  end
end
