# frozen_string_literal: true

module StatsDLoggable
  extend ActiveSupport::Concern

  included do
    before_action :log_request_to_statsd, unless: -> { LogSkip.should_skip?(params: params) }
  end

  private

  def log_request_to_statsd
    StatsD.increment("requests_by_action.#{params['controller']}-#{params['action']}")
    StatsD.increment("requests_by_user.#{current_user&.id || 0}")
  end
end
