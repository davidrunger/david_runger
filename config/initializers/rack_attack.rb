# frozen_string_literal: true

class Rack::Attack
  # Limit all IPs to 60 requests per clock minute
  # rubocop:disable Style/SymbolProc
  throttle('req/ip', limit: 60, period: 1.minute) do |req|
    req.ip
  end
  # rubocop:enable Style/SymbolProc
end
