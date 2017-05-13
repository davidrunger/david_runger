# == Schema Information
#
# Table name: requests
#
#  bot          :boolean          default("false"), not null
#  db           :integer
#  format       :string           not null
#  handler      :string           not null
#  id           :integer          not null, primary key
#  ip           :string           not null
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

class Request < ApplicationRecord
  belongs_to :user, optional: true

  scope :human, -> { where(bot: false) }
  scope :recent, ->(time_period = 1.day) do
    where('requests.requested_at > ?', time_period.ago)
  end
end
