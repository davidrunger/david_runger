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
#  user_agent         :text             not null
#  violated_directive :string           not null
#
FactoryBot.define do
  factory :csp_report do
    document_uri { "#{DavidRunger::CANONICAL_URL}emotional_needs/5/history?rated_user=partner" }
    violated_directive { 'script-src-elem' }
    original_policy do
      <<~POLICY.squish
        default-src 'none'; base-uri 'self'; connect-src 'self'; manifest-src 'self'; form-action
        'self'; font-src 'self' https: data:; img-src 'self' https: data:; object-src 'none';
        script-src 'self' 'nonce-#{SecureRandom.hex(16)}'; style-src 'self' https:
        'unsafe-inline'; frame-ancestors 'self'; report-uri /api/csp_reports
      POLICY
    end
    ip { Faker::Internet.public_ip_v6_address }
    referrer { "#{DavidRunger::CANONICAL_URL}check_ins/9" }
    blocked_uri { 'inline' }
    user_agent { Faker::Internet.user_agent }
  end
end
