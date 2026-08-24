# == Schema Information
#
# Table name: link_status_expectations
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  status     :integer          not null
#  updated_at :datetime         not null
#  url        :text             not null
#
# Indexes
#
#  index_link_status_expectations_on_url_and_status  (url,status) UNIQUE
#
FactoryBot.define do
  factory :link_status_expectation do
    sequence(:url) { |index| "https://example.com/redirects/#{index}" }
    status { 301 }
  end
end
