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
#  index_requests_on_isp            (isp)
#  index_requests_on_request_id     (request_id) UNIQUE
#  index_requests_on_requested_at   (requested_at)
#  index_requests_on_user_id        (user_id)
#
class Request < ApplicationRecord
  # error class for Rollbar logging
  class CreateRequestError < StandardError ; end

  belongs_to :admin_user, optional: true
  belongs_to :auth_token, optional: true
  belongs_to :user, optional: true

  validates :url, :handler, :method, :ip, :requested_at, :status, presence: true
  validates :request_id, presence: true, uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      admin_user_id
      auth_token_id
      db
      format
      handler
      id
      ip
      isp
      location
      method
      params
      referer
      request_id
      requested_at
      status
      total
      url
      user_agent
      user_id
      view
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[admin_user auth_token user]
  end
end
