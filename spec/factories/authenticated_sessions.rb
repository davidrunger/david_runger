# == Schema Information
#
# Table name: authenticated_sessions
#
#  authenticatable_id                    :bigint           not null
#  authenticatable_type                  :string           not null
#  authentication_kind                   :string           not null
#  created_at                            :datetime         not null
#  id                                    :bigint           not null, primary key
#  identifier                            :string           not null
#  initial_ip                            :string           not null
#  initial_user_agent                    :text             not null
#  initiated_by_authenticated_session_id :bigint
#  last_active_at                        :datetime         not null
#  latest_ip                             :string           not null
#  latest_user_agent                     :text             not null
#  revoked_at                            :datetime
#  updated_at                            :datetime         not null
#
# Indexes
#
#  idx_on_initiated_by_authenticated_session_id_b250d18242  (initiated_by_authenticated_session_id)
#  index_authenticated_sessions_for_account_listing         (authenticatable_type,authenticatable_id,revoked_at)
#  index_authenticated_sessions_on_identifier               (identifier) UNIQUE
#
FactoryBot.define do
  factory :authenticated_session do
    association :authenticatable, factory: :user
    authentication_kind { 'legacy' }
    initial_ip { Faker::Internet.ip_v4_address }
    latest_ip { initial_ip }
    initial_user_agent { 'Mozilla/5.0 Test Browser' }
    latest_user_agent { initial_user_agent }
    last_active_at { Time.current.change(sec: 0, usec: 0) }

    trait :admin do
      association :authenticatable, factory: :admin_user
    end
  end
end
