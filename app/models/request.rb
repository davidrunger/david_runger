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

class Request < ApplicationRecord
  # error class for Rollbar logging
  class CreateRequestError < StandardError ; end

  belongs_to :user, optional: true

  validates :url, :handler, :method, :format, :ip, :requested_at, presence: true

  scope :recent, (lambda do |time_period = 1.day|
    where('requests.requested_at > ?', Time.current - time_period.to_i) # use #to_i bc of DST stuff
  end)
  scope :ordered, ->() { order('requests.requested_at') }
end
