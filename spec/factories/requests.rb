# == Schema Information
#
# Table name: requests
#
#  db           :integer
#  format       :string           not null
#  handler      :string           not null
#  id           :bigint(8)        not null, primary key
#  ip           :string           not null
#  isp          :string
#  location     :string
#  method       :string           not null
#  params       :jsonb
#  referer      :string
#  requested_at :datetime         not null
#  status       :integer
#  url          :string           not null
#  user_agent   :string
#  user_id      :bigint(8)
#  view         :integer
#
# Indexes
#
#  index_requests_on_requested_at  (requested_at)
#  index_requests_on_user_id       (user_id)
#

FactoryBot.define do
  chrome_user_agent = <<-CHROME.squish
    Chrome 57 Macintosh mobile=false raw=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4)
    AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36
  CHROME

  factory :request do
    user_id { nil }
    url { 'http://davidrunger.com' }
    handler { 'home#index' }
    referer { nil }
    params { Hash.new }
    add_attribute(:method) { 'GET' }
    format { 'html' }
    status { 200 }
    view { 12 }
    db { 8 }
    ip { '77.88.47.71' }
    user_agent { chrome_user_agent }
    requested_at { 1.week.ago }
  end

  trait :chrome do
    user_agent { chrome_user_agent }
  end
end
