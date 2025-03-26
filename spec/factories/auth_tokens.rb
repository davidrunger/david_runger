# == Schema Information
#
# Table name: auth_tokens
#
#  created_at             :datetime         not null
#  id                     :bigint           not null, primary key
#  last_used_at           :datetime
#  name                   :text
#  permitted_actions_list :text
#  secret                 :text             not null
#  updated_at             :datetime         not null
#  user_id                :bigint           not null
#
# Indexes
#
#  index_auth_tokens_on_secret              (secret)
#  index_auth_tokens_on_user_id_and_secret  (user_id,secret) UNIQUE
#
FactoryBot.define do
  factory :auth_token do
    association :user
    secret { SecureRandom.uuid }
    name { 'browser shortcut' }
    last_used_at { 2.days.ago }
  end
end
