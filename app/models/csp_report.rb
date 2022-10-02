# frozen_string_literal: true

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
#  violated_directive :string           not null
#
class CspReport < ApplicationRecord
  validates :document_uri, presence: true
  validates :violated_directive, presence: true
  validates :original_policy, presence: true
  validates :ip, presence: true
end
