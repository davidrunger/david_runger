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
class LinkStatusExpectation < ApplicationRecord
  HTTP_URL_REGEX = /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/

  has_paper_trail_for_all_events

  validates(
    :status,
    presence: true,
    numericality: {
      greater_than_or_equal_to: 100,
      less_than_or_equal_to: 999,
      only_integer: true,
    },
    uniqueness: { scope: :url },
  )
  validates(
    :url,
    presence: true,
    format: { with: HTTP_URL_REGEX },
  )

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id status updated_at url]
  end
end
