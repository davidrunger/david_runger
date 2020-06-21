# frozen_string_literal: true

# == Schema Information
#
# Table name: requests
#
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
#  url           :string           not null
#  user_agent    :string
#  user_id       :bigint
#  view          :integer
#
# Indexes
#
#  index_requests_on_auth_token_id  (auth_token_id)
#  index_requests_on_isp            (isp)
#  index_requests_on_request_id     (request_id) UNIQUE
#  index_requests_on_requested_at   (requested_at)
#  index_requests_on_user_id        (user_id)
#

class Request < ApplicationRecord
  # error class for Rollbar logging
  class CreateRequestError < StandardError ; end

  belongs_to :auth_token, optional: true
  belongs_to :user, optional: true

  validates :url, :handler, :method, :ip, :requested_at, :status, presence: true
  validates :request_id, presence: true
end
