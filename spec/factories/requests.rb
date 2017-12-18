# == Schema Information
#
# Table name: requests
#
#  bot          :boolean          default(FALSE), not null
#  db           :integer
#  format       :string           not null
#  handler      :string           not null
#  id           :integer          not null, primary key
#  ip           :string           not null
#  location     :string
#  method       :string           not null
#  params       :jsonb
#  referer      :string
#  requested_at :datetime         not null
#  status       :integer
#  url          :string           not null
#  user_agent   :string
#  user_id      :integer
#  view         :integer
#
# Indexes
#
#  index_requests_on_requested_at  (requested_at)
#  index_requests_on_user_id       (user_id)
#

FactoryBot.define do
  bot_user_agent = <<-BOT.squish
    Generic Browser 0 Other mobile=false raw=Mozilla/5.0 (compatible; Googlebot/2.1;
    +http://www.google.com/bot.html)
  BOT

  chrome_user_agent = <<-CHROME.squish
    Chrome 57 Macintosh mobile=false raw=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4)
    AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36
  CHROME

  factory :request do
    user_id nil
    url 'http://davidrunger.com'
    handler 'home#index'
    referer nil
    params Hash.new
    add_attribute(:method) { 'GET' }
    format 'html'
    status 200
    view 12
    db 8
    ip '77.88.47.71'
    user_agent chrome_user_agent
    requested_at { 1.week.ago }
    bot false
  end

  trait :bot do
    user_agent bot_user_agent
    bot true
  end

  trait :chrome do
    user_agent chrome_user_agent
    bot false
  end
end
