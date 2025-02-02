# == Schema Information
#
# Table name: requests
#
#  admin_user_id :bigint
#  auth_token_id :bigint
#  db            :integer
#  format        :string
#  handler       :string           not null
#  id            :bigint           not null, primary key
#  ip            :string           not null
#  isp           :string
#  location      :string
#  method        :string           not null
#  params        :jsonb
#  referer       :string
#  request_id    :string           not null
#  requested_at  :datetime         not null
#  status        :integer          not null
#  total         :integer
#  url           :string           not null
#  user_agent    :string
#  user_id       :bigint
#  view          :integer
#
# Indexes
#
#  index_requests_on_admin_user_id  (admin_user_id)
#  index_requests_on_auth_token_id  (auth_token_id)
#  index_requests_on_handler        (handler)
#  index_requests_on_ip             (ip)
#  index_requests_on_request_id     (request_id) UNIQUE
#  index_requests_on_requested_at   (requested_at)
#  index_requests_on_user_id        (user_id)
#
FactoryBot.define do
  factory :request do
    request_id { SecureRandom.uuid }
    user_id { nil }
    url { DavidRunger::CANONICAL_URL }
    handler { 'home#index' }
    referer { 'https://github.com/davidrunger/david_runger' }
    params { {} }
    add_attribute(:method) { 'GET' }
    format { 'html' }
    status { 200 }
    view { rand(100) }
    db { rand(100) }
    total { view + db + rand(100) }
    ip { Faker::Internet.public_ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    requested_at { rand(1..14).days.ago }
    location do
      "#{Faker::Address.city}, #{Faker::Address.state_abbr}, #{Faker::Address.country_code}"
    end
    isp { Faker::Company.name }
  end
end
