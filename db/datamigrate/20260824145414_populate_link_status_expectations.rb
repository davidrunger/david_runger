# Run locally:
#   bin/rails runner db/datamigrate/20260824145414_populate_link_status_expectations.rb
#
# Run in production after this datamigration deploys:
#   bin/run-datamigration db/datamigrate/20260824145414_populate_link_status_expectations.rb

class PopulateLinkStatusExpectations < Datamigration::Base
  EXPECTATIONS = {
    'https://crystal-lang.org/reference/latest/' => [301],
    'https://www.appacademy.io/' => [403],
    'https://www.commonlit.org/' => [403],
    'https://www.linkedin.com/in/davidrunger' => [429, 999],
    'https://www.termsfeed.com/blog/cookies/#What_Are_Cookies' => [403],
    'https://www.termsfeed.com/privacy-policy-generator/' => [403],
  }.freeze

  def run
    within_transaction do
      EXPECTATIONS.each do |url, statuses|
        statuses.each { |status| LinkStatusExpectation.create!(url:, status:) }
      end
    end
  end
end

Datamigration::Runner.new(PopulateLinkStatusExpectations).run
