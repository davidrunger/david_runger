# frozen_string_literal: true

module DavidRunger::LogSkip
  def self.should_skip?(params: {})
    params['new_relic_ping'].present? && ENV['LOG_NEW_RELIC_PINGS'].blank?
  end
end
