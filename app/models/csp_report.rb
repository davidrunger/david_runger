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
  MAX_ORIGINAL_POLICY_LENGTH = 8.kilobytes
  MAX_URI_LENGTH = 2.kilobytes
  MAX_USER_AGENT_LENGTH = 1.kilobyte
  MAX_VIOLATED_DIRECTIVE_LENGTH = 1.kilobyte

  validates :document_uri, presence: true
  validates :violated_directive, presence: true
  validates :original_policy, presence: true
  validates :ip, presence: true
  validates :user_agent, presence: true
  validates(
    :blocked_uri,
    :document_uri,
    :referrer,
    length: { maximum: MAX_URI_LENGTH },
    allow_nil: true,
  )
  validates :original_policy, length: { maximum: MAX_ORIGINAL_POLICY_LENGTH }
  validates :user_agent, length: { maximum: MAX_USER_AGENT_LENGTH }
  validates :violated_directive, length: { maximum: MAX_VIOLATED_DIRECTIVE_LENGTH }

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
